-- Promote a designated account to the 'admin' role.
--
-- The backfill in 20260708000002_create_trigger_and_backfill.sql assigns
-- 'customer' to every pre-existing auth user, which demotes any account that
-- should be an admin. This migration re-promotes one account on every run.
--
-- SECURITY: No admin email is hardcoded here. The target email is read from a
-- Supabase Vault secret named 'admin_email', so the real address stays out of
-- version control while still persisting across database rebuilds.
--
-- One-time setup (run in the SQL editor, NOT committed anywhere):
--
--     select vault.create_secret('you@example.com', 'admin_email');
--
--   To rotate later:
--     select vault.update_secret(
--       (select id from vault.secrets where name = 'admin_email'),
--       'new@example.com');
--
-- If the secret is absent or empty, this migration is a safe no-op.

DO $$
DECLARE
  admin_email text;
BEGIN
  SELECT decrypted_secret
  INTO admin_email
  FROM vault.decrypted_secrets
  WHERE name = 'admin_email'
  LIMIT 1;

  IF admin_email IS NULL OR btrim(admin_email) = '' THEN
    RAISE NOTICE
      'Vault secret "admin_email" is not set; skipping admin promotion. '
      'Create it with vault.create_secret(...) — see this file''s comments.';
    RETURN;
  END IF;

  UPDATE public.profiles p
  SET role = 'admin'
  FROM auth.users u
  WHERE u.id = p.id
    AND u.email = btrim(admin_email);

  IF NOT FOUND THEN
    RAISE NOTICE 'No profile matched the admin_email secret; nothing promoted.';
  END IF;
END $$;
