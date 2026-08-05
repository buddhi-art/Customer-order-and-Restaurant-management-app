-- 1. Create a function to recalculate the total_amount for an order based on current menu item prices
CREATE OR REPLACE FUNCTION calculate_order_total()
RETURNS TRIGGER AS $$
DECLARE
    item_record jsonb;
    menu_item_price numeric;
    calculated_total numeric := 0;
BEGIN
    -- Iterate through the items JSON array
    FOR item_record IN SELECT * FROM jsonb_array_elements(NEW.items)
    LOOP
        -- Look up the actual price of the item from the menu_items table
        SELECT price INTO menu_item_price
        FROM menu_items
        WHERE id = (item_record->>'item_id')::uuid;

        -- If item exists, add to total
        IF FOUND THEN
            calculated_total := calculated_total + (menu_item_price * (item_record->>'quantity')::numeric);
        END IF;
    END LOOP;

    -- Overwrite whatever total_amount the client sent with our trusted calculated total
    NEW.total_amount := calculated_total;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on orders table
DROP TRIGGER IF EXISTS trg_enforce_order_pricing ON orders;
CREATE TRIGGER trg_enforce_order_pricing
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION calculate_order_total();

-- 2. Enforce Admin RLS
-- We create a function to check if the current user is an admin
CREATE OR REPLACE FUNCTION public.check_is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only admins can read all orders
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
CREATE POLICY "Admins can view all orders"
ON orders
FOR SELECT
USING (public.check_is_admin());

-- Only admins can update all orders (e.g. changing status)
DROP POLICY IF EXISTS "Admins can update all orders" ON orders;
CREATE POLICY "Admins can update all orders"
ON orders
FOR UPDATE
USING (public.check_is_admin());
