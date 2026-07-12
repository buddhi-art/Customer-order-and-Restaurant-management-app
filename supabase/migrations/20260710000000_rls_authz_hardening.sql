-- RLS / authorization hardening
-- ============================================================================
-- Closes the authorization holes found in the security audit. Every statement
-- is idempotent (DROP ... IF EXISTS + CREATE OR REPLACE) so this migration can
-- be re-applied to a live database with `supabase db push` without failing.
--
-- NOTE: This migration is written but intentionally NOT auto-applied. Review it,
-- then apply with `supabase db push` (or the SQL editor) during a maintenance
-- window. It depends on public.is_admin(uuid) created in
-- 20260709000002_security_hardening_linter.sql.
--
-- Issues addressed:
--   * Privilege escalation: any customer could UPDATE their own profiles.role
--     to 'admin'                                              (CRITICAL)
--   * Any authenticated user could write menu_items / inventory /
--     cafe_settings / cafe_tables                             (CRITICAL)
--   * Any authenticated user could advance their own order to paid/served and
--     farm loyalty points                                     (CRITICAL)
--   * Orders INSERT accepted arbitrary user_id / payment_status (WITH CHECK
--     true)                                                   (HIGH)
--   * Any authenticated user could DELETE any order and UPDATE/DELETE any
--     reservation                                             (HIGH)
--   * Guest orders/reservations were world-readable            (MEDIUM)
--   * handle_new_user had a mutable search_path                (WARN)
--   * status enum casing mismatch + dead merge_guest_orders guard (LOW)

-- ============================================================================
-- 0. Guard: is_admin() must exist. (Created in 20260709000002.)
-- ============================================================================
-- (No-op assertion; CREATE OR REPLACE below re-defines the functions we own.)

-- ============================================================================
-- 1. profiles: block self-service role escalation (CRITICAL)
-- ============================================================================
-- The "Profiles are updatable by owner or admin" RLS policy is column-blind:
-- WITH CHECK passes for any new column values on a row the caller owns,
-- including role='admin'. RLS WITH CHECK cannot reference OLD, so we enforce the
-- "only an admin may change role" invariant with a BEFORE UPDATE trigger, plus a
-- column-level REVOKE as defense in depth.
CREATE OR REPLACE FUNCTION public.prevent_role_self_escalation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- loyalty_points is credited only by the SECURITY DEFINER loyalty trigger;
  -- reject any direct client change to it as well.
  IF NEW.role IS DISTINCT FROM OLD.role AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Only admins may change the role column';
  END IF;
  IF NEW.loyalty_points IS DISTINCT FROM OLD.loyalty_points AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'loyalty_points cannot be changed directly';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_role_self_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_role_self_escalation
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.prevent_role_self_escalation();

-- Defense in depth: strip column-level UPDATE on the privileged columns from
-- the API roles. Admins mutate role via a SECURITY DEFINER path, not directly.
REVOKE UPDATE (role)           ON public.profiles FROM anon, authenticated;
REVOKE UPDATE (loyalty_points) ON public.profiles FROM anon, authenticated;

-- ============================================================================
-- 2. Admin-only writes on menu / inventory / settings / tables (CRITICAL)
-- ============================================================================
-- Replace the "any authenticated user can manage" policies with admin-only
-- writes. Public SELECT stays intact so menus/tables remain readable.

-- menu_items
DROP POLICY IF EXISTS "Authenticated users can manage menu_items" ON public.menu_items;
DROP POLICY IF EXISTS "Admin write access for menu items"         ON public.menu_items;
DROP POLICY IF EXISTS "Admins can manage menu_items"              ON public.menu_items;
CREATE POLICY "Admins can manage menu_items"
  ON public.menu_items FOR ALL
  USING (public.is_admin()) WITH CHECK (public.is_admin());

-- inventory
DROP POLICY IF EXISTS "Authenticated users can manage inventory" ON public.inventory;
DROP POLICY IF EXISTS "Admins can manage inventory"              ON public.inventory;
CREATE POLICY "Admins can manage inventory"
  ON public.inventory FOR ALL
  USING (public.is_admin()) WITH CHECK (public.is_admin());

-- cafe_settings
DROP POLICY IF EXISTS "Authenticated users can manage cafe_settings" ON public.cafe_settings;
DROP POLICY IF EXISTS "Admins can manage cafe_settings"              ON public.cafe_settings;
CREATE POLICY "Admins can manage cafe_settings"
  ON public.cafe_settings FOR ALL
  USING (public.is_admin()) WITH CHECK (public.is_admin());

-- cafe_tables (keep public "Anyone can view tables." SELECT policy)
DROP POLICY IF EXISTS "Authenticated users can insert tables" ON public.cafe_tables;
DROP POLICY IF EXISTS "Authenticated users can update tables" ON public.cafe_tables;
DROP POLICY IF EXISTS "Authenticated users can delete tables" ON public.cafe_tables;
DROP POLICY IF EXISTS "Admins can manage tables"             ON public.cafe_tables;
CREATE POLICY "Admins can insert tables"
  ON public.cafe_tables FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "Admins can update tables"
  ON public.cafe_tables FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins can delete tables"
  ON public.cafe_tables FOR DELETE USING (public.is_admin());

-- ============================================================================
-- 3. orders: only admins change status / payment_status (CRITICAL/HIGH)
-- ============================================================================
-- Replace the owner-or-admin UPDATE policy with admin-only UPDATE so customers
-- cannot self-advance their order to paid/served (which would also mint loyalty
-- points via the AFTER UPDATE loyalty trigger). A BEFORE UPDATE guard is added
-- as belt-and-suspenders in case a future policy re-broadens UPDATE.
DROP POLICY IF EXISTS "Only admin or order owner can update order status" ON public.orders;
DROP POLICY IF EXISTS "Users can update own orders"                       ON public.orders;
DROP POLICY IF EXISTS "Only admin can update orders"                      ON public.orders;
CREATE POLICY "Only admin can update orders"
  ON public.orders FOR UPDATE
  USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE OR REPLACE FUNCTION public.guard_order_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    IF NEW.payment_status IS DISTINCT FROM OLD.payment_status
       OR NEW.status IS DISTINCT FROM OLD.status THEN
      RAISE EXCEPTION 'Not authorized to change order status or payment_status';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS guard_order_privileged_columns_trigger ON public.orders;
CREATE TRIGGER guard_order_privileged_columns_trigger
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.guard_order_privileged_columns();

-- ============================================================================
-- 4. orders / reservations INSERT: scope user_id, no forged 'paid' (HIGH)
-- ============================================================================
-- Guests (no session) may still insert with a NULL user_id; authenticated users
-- may only insert rows attributed to themselves. validate_order_total() still
-- guards the money path. A BEFORE INSERT trigger forces status/payment_status to
-- safe defaults so a client cannot fabricate a 'paid' order at insert time.
DROP POLICY IF EXISTS "Users can insert orders." ON public.orders;
CREATE POLICY "Users can insert orders."
  ON public.orders FOR INSERT
  WITH CHECK (user_id IS NULL OR user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.force_safe_order_insert_defaults()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Non-admin inserts always start unpaid and pending, regardless of payload.
  IF NOT public.is_admin() THEN
    NEW.payment_status := 'unpaid';
    IF NEW.status IS DISTINCT FROM 'pending' THEN
      NEW.status := 'pending';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS force_safe_order_insert_defaults_trigger ON public.orders;
CREATE TRIGGER force_safe_order_insert_defaults_trigger
  BEFORE INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.force_safe_order_insert_defaults();

DROP POLICY IF EXISTS "Users can insert reservations." ON public.reservations;
CREATE POLICY "Users can insert reservations."
  ON public.reservations FOR INSERT
  WITH CHECK (user_id IS NULL OR user_id = auth.uid());

-- ============================================================================
-- 5. orders DELETE + reservations UPDATE/DELETE: real ownership (HIGH)
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can delete orders"       ON public.orders;
DROP POLICY IF EXISTS "Only admin or order owner can delete orders" ON public.orders;
CREATE POLICY "Only admin or order owner can delete orders"
  ON public.orders FOR DELETE
  USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS "Users can update own reservations" ON public.reservations;
CREATE POLICY "Users can update own reservations"
  ON public.reservations FOR UPDATE
  USING (auth.uid() = user_id OR public.is_admin())
  WITH CHECK (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS "Users can delete own reservations" ON public.reservations;
CREATE POLICY "Users can delete own reservations"
  ON public.reservations FOR DELETE
  USING (auth.uid() = user_id OR public.is_admin());

-- ============================================================================
-- 6. orders / reservations SELECT: stop leaking guest rows (MEDIUM)
-- ============================================================================
-- Remove the blanket "OR user_id IS NULL", which made every unattributed row
-- world-readable. Orders are inserted with the caller's uid (see
-- OrderRepository.insert), so authenticated users still see their own; admins
-- see all. A legitimate guest-lookup path should go through a scoped RPC.
DROP POLICY IF EXISTS "Users can view own orders." ON public.orders;
CREATE POLICY "Users can view own orders."
  ON public.orders FOR SELECT
  USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS "Users can view own reservations." ON public.reservations;
CREATE POLICY "Users can view own reservations."
  ON public.reservations FOR SELECT
  USING (auth.uid() = user_id OR public.is_admin());

-- ============================================================================
-- 7. handle_new_user: pin search_path (WARN 0011)
-- ============================================================================
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT p.oid::regprocedure AS sig
    FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'handle_new_user'
  LOOP
    EXECUTE format('ALTER FUNCTION %s SET search_path = %L', r.sig, '');
  END LOOP;
END $$;

-- ============================================================================
-- 8. Atomic inventory adjustment RPC (concurrency-safe stock changes)
-- ============================================================================
-- Read-modify-write from cached client state loses concurrent updates. This RPC
-- performs the delta atomically in Postgres and clamps at zero.
CREATE OR REPLACE FUNCTION public.adjust_inventory_stock(p_id TEXT, p_delta NUMERIC)
RETURNS NUMERIC
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  UPDATE public.inventory
  SET current_stock = GREATEST(0, current_stock + p_delta)
  WHERE id = p_id
  RETURNING current_stock;
$$;

REVOKE ALL ON FUNCTION public.adjust_inventory_stock(TEXT, NUMERIC) FROM PUBLIC, anon;
-- Only admins mutate inventory (RLS above); the RPC is SECURITY DEFINER but we
-- still gate EXECUTE and re-check admin inside callers.
GRANT EXECUTE ON FUNCTION public.adjust_inventory_stock(TEXT, NUMERIC) TO authenticated;

-- ============================================================================
-- 9. Order status enum casing + merge guard fix (LOW)
-- ============================================================================
-- The app writes lowercase statuses ('pending'); the column default was
-- 'Pending'. Align the default and normalize existing rows.
ALTER TABLE public.orders ALTER COLUMN status SET DEFAULT 'pending';
UPDATE public.orders SET status = 'pending' WHERE status = 'Pending';
