-- Security hardening migration
-- Addresses audit issues #4 (over-permissive orders UPDATE RLS) and
-- #5/#18 (server-side order total validation).
--
-- Idempotent: safe to run regardless of whether earlier role/RLS migrations
-- were applied, and converges to a single canonical policy.

-- =============================================================================
-- 1. Orders UPDATE RLS — only the order owner or an admin (issue #4)
-- =============================================================================
-- Drop every historical variant so exactly one canonical policy remains.
DROP POLICY IF EXISTS "Users can update own orders" ON public.orders;
DROP POLICY IF EXISTS "Only admin or order owner can update order status"
  ON public.orders;

CREATE POLICY "Only admin or order owner can update order status"
  ON public.orders FOR UPDATE
  USING (
    auth.uid() = user_id
    OR auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
  )
  WITH CHECK (
    auth.uid() = user_id
    OR auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
  );

-- =============================================================================
-- 2. Server-side order total validation (issues #5, #18)
-- =============================================================================
-- The client sends `total_amount` and an `items` JSONB array where each element
-- carries a client-supplied `price`. Neither can be trusted. This trigger
-- recomputes the authoritative total from the live `menu_items` table (falling
-- back to the embedded price only when the item is not found, e.g. a since-
-- deleted item) plus the configured tax rate, and rejects the row if the client
-- total deviates beyond a small rounding epsilon.
CREATE OR REPLACE FUNCTION public.validate_order_total()
RETURNS TRIGGER AS $$
DECLARE
  item             JSONB;
  item_id          TEXT;
  qty              NUMERIC;
  unit_price       NUMERIC;
  size_mult        NUMERIC;
  subtotal         NUMERIC := 0;
  tax_rate         NUMERIC := 0;
  expected_total   NUMERIC;
  epsilon          NUMERIC := 0.05;  -- absolute currency tolerance
BEGIN
  -- Sum authoritative line totals.
  FOR item IN SELECT * FROM jsonb_array_elements(NEW.items)
  LOOP
    item_id := item->>'item_id';
    qty := GREATEST(1, COALESCE((item->>'quantity')::NUMERIC, 1));

    -- Size multiplier must mirror CartItem._sizeMultipliers on the client.
    size_mult := CASE item->>'size'
      WHEN 'Small' THEN 0.75
      WHEN 'Large' THEN 1.35
      ELSE 1.0            -- Medium / unknown
    END;

    -- Prefer the current DB price; reject the order if the menu item is invalid.
    SELECT price INTO unit_price
    FROM public.menu_items
    WHERE menu_items.item_id = item_id;

    IF unit_price IS NULL THEN
      RAISE EXCEPTION 'Invalid menu item: %', item_id;
    END IF;

    subtotal := subtotal + (unit_price * qty * size_mult);
  END LOOP;

  -- Tax rate is stored as a percentage in cafe_settings (e.g. 13.0 = 13%).
  -- Convert to a fraction, and mirror the client's fallback of 13% when the
  -- configured rate is zero/unset (see checkout_screen.dart).
  SELECT COALESCE(cafe_settings.tax_rate, 0) INTO tax_rate
  FROM public.cafe_settings
  ORDER BY id
  LIMIT 1;

  tax_rate := COALESCE(tax_rate, 0) / 100.0;
  IF tax_rate <= 0 THEN
    tax_rate := 0.13;
  END IF;

  expected_total := subtotal * (1 + tax_rate);

  IF ABS(COALESCE(NEW.total_amount, 0) - expected_total) > epsilon THEN
    RAISE EXCEPTION
      'Order total mismatch: client sent %, server computed % (subtotal %, tax_rate %)',
      NEW.total_amount, expected_total, subtotal, tax_rate;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS validate_order_total_trigger ON public.orders;
CREATE TRIGGER validate_order_total_trigger
  BEFORE INSERT OR UPDATE OF items, total_amount ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_order_total();
