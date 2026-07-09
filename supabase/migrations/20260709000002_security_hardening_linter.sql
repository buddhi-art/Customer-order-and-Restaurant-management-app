-- Security hardening (linter follow-up)
-- ============================================================================
-- Resolves the remaining Supabase database-linter findings AFTER the drifted
-- objects are removed (see 20260709000001_drop_drifted_objects.sql). Covers:
--   * 0011 function_search_path_mutable        -> pin search_path
--   * 0028/0029 security_definer_executable    -> REVOKE EXECUTE from anon/auth
--   * profiles "any profile" over-broad access -> self-or-admin scoped policies
--
-- Guest-checkout INSERT policies on orders/reservations are intentionally left
-- as WITH CHECK (true): they are required for pre-sign-in ordering and the
-- money path is already guarded by validate_order_total(). Public SELECT on
-- menu_items/cafe_settings/cafe_tables is likewise by design.

-- ============================================================================
-- 1. Pin search_path on every SECURITY DEFINER / trigger function (0011)
-- ============================================================================
-- Applies to whatever migration-defined functions actually exist. Empty
-- search_path forces fully-qualified names inside the function bodies (all of
-- ours already schema-qualify as public.<table>), closing the hijack vector.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT p.oid::regprocedure AS sig
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname IN (
        'validate_order_total',
        'handle_new_user',
        'handle_order_payment_success',
        'merge_guest_orders'
      )
  LOOP
    EXECUTE format('ALTER FUNCTION %s SET search_path = %L', r.sig, '');
    RAISE NOTICE 'Pinned search_path on %', r.sig;
  END LOOP;
END $$;

-- ============================================================================
-- 2. Revoke EXECUTE on SECURITY DEFINER functions from anon/authenticated
--    (0028, 0029)
-- ============================================================================
-- None of these are called as RPCs by the app -- they run as triggers
-- (validate_order_total, handle_new_user, handle_order_payment_success) or are
-- invoked server-side. Removing the API-exposed EXECUTE grant stops them from
-- being callable via /rest/v1/rpc/*. merge_guest_orders is a SECURITY DEFINER
-- RPC that is currently unused by the client; revoke it too and re-grant
-- explicitly if/when the merge flow is wired up.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT p.oid::regprocedure AS sig
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname IN (
        'validate_order_total',
        'handle_new_user',
        'handle_order_payment_success',
        'merge_guest_orders'
      )
  LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon, authenticated', r.sig);
    RAISE NOTICE 'Revoked EXECUTE on %', r.sig;
  END LOOP;
END $$;

-- ============================================================================
-- 3. profiles: replace over-broad "any profile" access with self-or-admin
-- ============================================================================
-- The admin members screen must read every profile, so we cannot restrict
-- SELECT to self only. Scope both read and write to: the row owner OR an admin.
--
-- IMPORTANT: a profiles policy that sub-selects `profiles` recurses infinitely
-- (Postgres 42P17). We therefore check admin status through a SECURITY DEFINER
-- helper that bypasses RLS on its internal read. This helper MUST stay
-- executable by `authenticated` for the policy to evaluate -- that is the
-- documented Supabase pattern, so a residual 0029 lint on is_admin() alone is
-- expected and acceptable. It is NOT a callable app RPC (returns only a boolean
-- about the current user) and anon EXECUTE is revoked.
CREATE OR REPLACE FUNCTION public.is_admin(uid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = uid AND role = 'admin'
  );
$$;

REVOKE ALL ON FUNCTION public.is_admin(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_admin(UUID) TO authenticated;

DROP POLICY IF EXISTS "Authenticated users can view any profile"   ON public.profiles;
DROP POLICY IF EXISTS "Authenticated users can update any profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile."                ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile."              ON public.profiles;
DROP POLICY IF EXISTS "Profiles are viewable by owner or admin"    ON public.profiles;
DROP POLICY IF EXISTS "Profiles are updatable by owner or admin"   ON public.profiles;

CREATE POLICY "Profiles are viewable by owner or admin"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id OR public.is_admin());

CREATE POLICY "Profiles are updatable by owner or admin"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id OR public.is_admin())
  WITH CHECK (auth.uid() = id OR public.is_admin());

-- ============================================================================
-- 4. notifications: reconcile policies (fixes RLS-enabled-no-policies)
-- ============================================================================
-- The live table had only the drifted "Allow public ..." policies; dropping
-- those alone would leave RLS enabled with ZERO policies -> default-deny ->
-- notification reads break for everyone. Drop every historical/drifted variant
-- and recreate the canonical pair the app needs:
--   * public SELECT  -- guests read notifications (notification_repository)
--   * admin-only writes -- only the admin management screen mutates them
DROP POLICY IF EXISTS "Allow public all access"                  ON public.notifications;
DROP POLICY IF EXISTS "Allow public read access"                 ON public.notifications;
DROP POLICY IF EXISTS "Anyone can view notifications"            ON public.notifications;
DROP POLICY IF EXISTS "Authenticated users can manage notifications" ON public.notifications;
DROP POLICY IF EXISTS "Public read access for notifications"     ON public.notifications;
DROP POLICY IF EXISTS "Admins can manage notifications"          ON public.notifications;

CREATE POLICY "Public read access for notifications"
  ON public.notifications FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage notifications"
  ON public.notifications FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());
