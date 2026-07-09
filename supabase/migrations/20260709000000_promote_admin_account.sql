-- Promote a designated account to the 'admin' role.
--
-- The backfill in 20260708000002_create_trigger_and_backfill.sql assigns
-- 'customer' to every pre-existing auth user, which demotes any account that
-- should be an admin. This migration re-promotes one account.
--
-- SECURITY: No admin email is hardcoded here. The target email is read from a
-- runtime setting so real credentials stay out of version control. Provide it
-- one of two ways:
--
--   1. Per-session, immediately before applying this migration:
--        SET app.admin_email = 'you@example.com';
--
--   2. Persisted on the database (survives future runs):
--        ALTER DATABASE postgres SET app.admin_email = 'you@example.com';
--
-- If the setting is absent or empty, this migration is a safe no-op.

DO $$
DECLARE
  admin_email text := current_setting('app.admin_email', true);
BEGIN
  IF admin_email IS NULL OR btrim(admin_email) = '' THEN
    RAISE NOTICE
      'app.admin_email is not set; skipping admin promotion. '
      'Set it (see comments) or run the UPDATE manually in the SQL editor.';
    RETURN;
  END IF;

  UPDATE public.profiles p
  SET role = 'admin'
  FROM auth.users u
  WHERE u.id = p.id
    AND u.email = btrim(admin_email);

  IF NOT FOUND THEN
    RAISE NOTICE 'No profile matched app.admin_email = %; nothing promoted.', admin_email;
  END IF;
END $$;
