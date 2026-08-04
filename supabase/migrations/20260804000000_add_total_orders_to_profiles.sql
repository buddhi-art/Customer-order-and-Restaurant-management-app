-- Migration: Add total_orders to profiles and maintain it via a trigger

-- 1. Add the column
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS total_orders INTEGER DEFAULT 0;

-- 2. Backfill existing counts
UPDATE public.profiles p
SET total_orders = (
  SELECT COUNT(*)
  FROM public.orders o
  WHERE o.user_id = p.id
);

-- 3. Create the trigger function
CREATE OR REPLACE FUNCTION public.increment_total_orders()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NOT NULL THEN
    UPDATE public.profiles
    SET total_orders = total_orders + 1
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Attach the trigger
DROP TRIGGER IF EXISTS increment_total_orders_trigger ON public.orders;
CREATE TRIGGER increment_total_orders_trigger
  AFTER INSERT ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.increment_total_orders();
