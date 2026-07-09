-- Issue 12: RLS policy to prevent unauthorized order status updates
-- Only the order owner (user_id) or an admin can update an order.
--
-- This replaces the permissive "Users can update own orders" policy from
-- the initial schema that allowed ANY authenticated user to update orders.

DROP POLICY IF EXISTS "Users can update own orders" ON public.orders;

DROP POLICY IF EXISTS "Only admin or order owner can update order status" ON orders;

CREATE POLICY "Only admin or order owner can update order status"
ON orders FOR UPDATE
USING (
  auth.uid() = user_id
  OR auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
);
