-- Drop drifted database objects
-- ============================================================================
-- These objects exist in the live Supabase database but were created ad-hoc in
-- the dashboard SQL editor -- they appear in NO local migration and are
-- referenced NOWHERE in the Flutter app (verified: zero `.rpc()` calls, no
-- table/function references anywhere under the repo). They form an abandoned
-- HR / equipment / invoicing prototype. Per the decision to keep the database
-- schema equal to the migration history, they are removed here.
--
-- Idempotent and signature-tolerant: uses IF EXISTS + a pg_proc sweep so it
-- succeeds whether or not the objects are present, and regardless of the exact
-- argument signatures (several were unknown from the linter output).

-- 1. Drop drifted functions by name (any overload) -------------------------
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
        'calculate_employee_kpi',
        'get_employee_kpi_breakdown',
        'recompute_all_kpis',
        'get_admin_dashboard_metrics',
        'checkout_equipment',
        'generate_invoice_number',
        'check_order_total',
        'is_admin_or_founder',
        'rls_auto_enable'
      )
  LOOP
    EXECUTE 'DROP FUNCTION IF EXISTS ' || r.sig || ' CASCADE';
    RAISE NOTICE 'Dropped drifted function %', r.sig;
  END LOOP;
END $$;

-- 2. Drop drifted table (removes its RLS policies via CASCADE) -------------
DROP TABLE IF EXISTS public.employee_kpi_snapshots CASCADE;

-- 3. Drifted RLS policies -------------------------------------------------
-- The drifted notifications policies ("Allow public all access" / "Allow
-- public read access") AND the drifted profiles "... any profile" policies are
-- handled in the companion hardening migration (20260709000002): they are
-- dropped AND replaced with canonical policies there, in one place, so the
-- tables are never left with RLS enabled but zero policies (which would
-- default-deny all access and break notification reads / the admin members
-- screen).
