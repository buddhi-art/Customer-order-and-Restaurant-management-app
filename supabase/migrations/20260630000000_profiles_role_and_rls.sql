-- Migration: add admin role to profiles + tighten orders RLS
--
-- 1. Add a `role` column to `public.profiles` (defaults to 'customer').
-- 2. Replace the over-permissive "Users can update own orders" policy with one
--    that only allows the order owner OR an admin to UPDATE the `orders` row.

-- 1. Add role column -------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'customer';

-- Backfill: the very first authenticated user is the admin. Subsequent
-- promotions are done manually via the Supabase dashboard.
-- (Leaving it as 'customer' here keeps the migration safe in production.)

-- 2. Replace the loose orders UPDATE policy --------------------------------
DROP POLICY IF EXISTS "Users can update own orders" ON public.orders;
DROP POLICY IF EXISTS "Only admin or order owner can update order status"
  ON public.orders;

CREATE POLICY "Only admin or order owner can update order status"
  ON public.orders FOR UPDATE
  USING (
    auth.uid() = user_id
    OR auth.uid() IN (
      SELECT id FROM public.profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    auth.uid() = user_id
    OR auth.uid() IN (
      SELECT id FROM public.profiles WHERE role = 'admin'
    )
  );

-- Helpful index for the admin sub-select.
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
