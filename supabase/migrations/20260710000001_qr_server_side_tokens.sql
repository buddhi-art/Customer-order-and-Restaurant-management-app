-- Server-side QR table-token generation & verification
-- ============================================================================
-- Moves the QR HMAC secret OFF the client. Previously QR_HMAC_SECRET was bundled
-- in assets/app.env and used client-side to both sign (admin) and verify
-- (consumer) `kalpa://<tableId>.<ts>.<hmac>` tokens — so anyone who unpacked a
-- build could extract the key and forge tokens for any table.
--
-- After this migration the secret lives only in Supabase Vault and both signing
-- and verification happen server-side via SECURITY DEFINER RPCs. The token
-- string format is unchanged so nothing else needs to understand it.
--
-- Requires: pgcrypto (hmac / gen_random_bytes), supabase_vault. Both present.

-- ----------------------------------------------------------------------------
-- 1. Store a strong secret in Vault (once). Regenerating is a no-op if present.
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM vault.secrets WHERE name = 'qr_hmac_secret') THEN
    PERFORM vault.create_secret(
      encode(extensions.gen_random_bytes(32), 'hex'),
      'qr_hmac_secret',
      'HMAC-SHA256 secret for signing QR table tokens (server-side only).'
    );
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 2. Internal helper: read the secret from Vault (owner-only).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public._qr_secret()
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
  SELECT decrypted_secret
  FROM vault.decrypted_secrets
  WHERE name = 'qr_hmac_secret'
  LIMIT 1;
$$;
REVOKE ALL ON FUNCTION public._qr_secret() FROM PUBLIC, anon, authenticated;

-- ----------------------------------------------------------------------------
-- 3. generate_table_qr(tableId) -> token  (ADMIN ONLY)
-- ----------------------------------------------------------------------------
-- Returns `kalpa://<tableId>.<ts>.<hmac_hex>` where ts is server unix-seconds
-- and hmac = HMAC-SHA256(tableId || '.' || ts, secret). Admin-gated so only
-- staff can mint the codes printed on tables.
CREATE OR REPLACE FUNCTION public.generate_table_qr(p_table_id TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_secret TEXT;
  v_ts     BIGINT;
  v_msg    TEXT;
  v_hmac   TEXT;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins can generate table QR codes';
  END IF;
  IF p_table_id IS NULL OR btrim(p_table_id) = '' THEN
    RAISE EXCEPTION 'table id is required';
  END IF;

  v_secret := public._qr_secret();
  IF v_secret IS NULL THEN
    RAISE EXCEPTION 'QR secret is not configured';
  END IF;

  v_ts  := floor(extract(epoch FROM now()))::BIGINT;
  v_msg := p_table_id || '.' || v_ts::TEXT;
  v_hmac := encode(
    extensions.hmac(v_msg, v_secret, 'sha256'),
    'hex'
  );

  RETURN 'kalpa://' || p_table_id || '.' || v_ts::TEXT || '.' || v_hmac;
END;
$$;

-- ----------------------------------------------------------------------------
-- 4. redeem_table_qr(token) -> tableId  (ANY caller; unforgeable)
-- ----------------------------------------------------------------------------
-- Recomputes the HMAC with the server-held secret and validates freshness
-- against SERVER time (device clock is irrelevant). Returns the trusted table
-- id on success, or NULL if the token is invalid/expired. Callable by guests
-- (anon) since scanning may happen before sign-in; it reveals only whether a
-- token is valid and its table id — never the secret.
CREATE OR REPLACE FUNCTION public.redeem_table_qr(p_token TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_secret   TEXT;
  v_body     TEXT;
  v_parts    TEXT[];
  v_table_id TEXT;
  v_ts_text  TEXT;
  v_provided TEXT;
  v_ts       BIGINT;
  v_age      BIGINT;
  v_expected TEXT;
BEGIN
  IF p_token IS NULL OR left(p_token, 8) <> 'kalpa://' THEN
    RETURN NULL;
  END IF;

  v_body  := substr(p_token, 9);          -- strip 'kalpa://'
  v_parts := string_to_array(v_body, '.');
  IF array_length(v_parts, 1) <> 3 THEN
    RETURN NULL;
  END IF;

  v_table_id := v_parts[1];
  v_ts_text  := v_parts[2];
  v_provided := v_parts[3];

  -- timestamp must be an integer
  BEGIN
    v_ts := v_ts_text::BIGINT;
  EXCEPTION WHEN others THEN
    RETURN NULL;
  END;

  -- freshness window: not older than 24h, not more than 5m in the future
  v_age := floor(extract(epoch FROM now()))::BIGINT - v_ts;
  IF v_age > 86400 OR v_age < -300 THEN
    RETURN NULL;
  END IF;

  v_secret := public._qr_secret();
  IF v_secret IS NULL THEN
    RETURN NULL;
  END IF;

  v_expected := encode(
    extensions.hmac(v_table_id || '.' || v_ts_text, v_secret, 'sha256'),
    'hex'
  );

  IF v_expected = v_provided THEN
    RETURN v_table_id;
  END IF;
  RETURN NULL;
END;
$$;

-- ----------------------------------------------------------------------------
-- 5. Grants: generate = authenticated (admin re-checked inside); redeem = all.
-- ----------------------------------------------------------------------------
REVOKE ALL ON FUNCTION public.generate_table_qr(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.generate_table_qr(TEXT) TO authenticated;

REVOKE ALL ON FUNCTION public.redeem_table_qr(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.redeem_table_qr(TEXT) TO anon, authenticated;
