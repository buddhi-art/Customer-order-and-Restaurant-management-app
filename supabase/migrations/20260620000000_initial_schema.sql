-- Kalpa Initial Schema Migration

-- WARNING: If you are getting an error like "column 'user_id' does not exist" 
-- or "Perhaps you meant to reference the column 'orders.order_id'", it means you have 
-- an old 'orders' table in your database from a previous test or tutorial.
-- 
-- The new app schema requires the tables to have specific columns (like id, user_id).
-- If you don't care about the old test data, you can uncomment the following lines to 
-- delete the old tables before creating the new ones:

-- DROP TABLE IF EXISTS public.orders CASCADE;
-- DROP TABLE IF EXISTS public.reservations CASCADE;
-- DROP TABLE IF EXISTS public.cafe_tables CASCADE;
-- DROP TABLE IF EXISTS public.profiles CASCADE;
-- DROP TABLE IF EXISTS public.inventory CASCADE;
-- DROP TABLE IF EXISTS public.cafe_settings CASCADE;
-- DROP TABLE IF EXISTS public.menu_items CASCADE;
-- DROP TABLE IF EXISTS public.notifications CASCADE;

-- 1. Create Tables

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone_number TEXT UNIQUE,
  date_of_birth DATE,
  loyalty_points INTEGER DEFAULT 0,
  is_profile_complete BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS public.cafe_tables (
  id SERIAL PRIMARY KEY,
  table_number INTEGER UNIQUE NOT NULL,
  status TEXT DEFAULT 'available'
);

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  table_id INTEGER REFERENCES public.cafe_tables(id) ON DELETE SET NULL,
  items JSONB NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'Pending',
  payment_status TEXT DEFAULT 'unpaid',
  payment_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.reservations (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  table_id INTEGER REFERENCES public.cafe_tables(id) ON DELETE CASCADE,
  reservation_time TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS public.inventory (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  current_stock DECIMAL(10, 2) NOT NULL DEFAULT 0,
  min_stock DECIMAL(10, 2) NOT NULL DEFAULT 0,
  unit TEXT NOT NULL,
  cost_per_unit DECIMAL(10, 2) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.cafe_settings (
  id INTEGER PRIMARY KEY DEFAULT 1,
  cafe_name TEXT NOT NULL,
  currency_symbol TEXT NOT NULL,
  tax_rate DECIMAL(5, 2) NOT NULL DEFAULT 0,
  service_charge_rate DECIMAL(5, 2) NOT NULL DEFAULT 0,
  enable_table_scanning BOOLEAN NOT NULL DEFAULT true,
  enable_geofence BOOLEAN NOT NULL DEFAULT false,
  wifi_ssid TEXT,
  wifi_bssid TEXT,
  cafe_latitude DECIMAL(10, 7),
  cafe_longitude DECIMAL(10, 7),
  geofence_radius_meters DECIMAL(10, 2) NOT NULL DEFAULT 25,
  opening_time TEXT,
  closing_time TEXT,
  closed_days JSONB DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS public.menu_items (
  item_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL DEFAULT 0,
  image_url TEXT,
  description TEXT,
  category TEXT NOT NULL,
  rating DECIMAL(3, 2) NOT NULL DEFAULT 0,
  volume_ml INTEGER NOT NULL DEFAULT 0,
  is_available BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Setup RLS (Row Level Security) - Basic initial rules
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cafe_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cafe_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Allow users to read/update their own profile
CREATE POLICY "Users can view own profile." ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);
-- Allow public access to read tables
CREATE POLICY "Anyone can view tables." ON public.cafe_tables FOR SELECT USING (true);
-- Allow users to read their own orders (and guests to read orders by table if managed via app logic)
CREATE POLICY "Users can view own orders." ON public.orders FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users can insert orders." ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can view own reservations." ON public.reservations FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users can insert reservations." ON public.reservations FOR INSERT WITH CHECK (true);

-- =============================================================================
-- Additional RLS Policies (UPDATE/DELETE guards)
-- =============================================================================

-- cafe_tables: Authenticated users can INSERT/UPDATE/DELETE; anyone can SELECT
CREATE POLICY "Authenticated users can insert tables"
  ON public.cafe_tables FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update tables"
  ON public.cafe_tables FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete tables"
  ON public.cafe_tables FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- orders: Users can UPDATE their own orders; authenticated users can UPDATE any
CREATE POLICY "Users can update own orders"
  ON public.orders FOR UPDATE
  USING (auth.uid() = user_id OR auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete orders"
  ON public.orders FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- reservations: Users can UPDATE/DELETE own reservations
CREATE POLICY "Users can update own reservations"
  ON public.reservations FOR UPDATE
  USING (auth.uid() = user_id OR auth.uid() IS NOT NULL);

CREATE POLICY "Users can delete own reservations"
  ON public.reservations FOR DELETE
  USING (auth.uid() = user_id OR auth.uid() IS NOT NULL);

-- profiles: Authenticated users can read any profile
CREATE POLICY "Authenticated users can view any profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id OR auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update any profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() IS NOT NULL);

-- inventory: Authenticated users can do everything, anyone can SELECT
CREATE POLICY "Anyone can view inventory" ON public.inventory FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage inventory" ON public.inventory USING (auth.uid() IS NOT NULL);

-- cafe_settings: Authenticated users can do everything, anyone can SELECT
CREATE POLICY "Anyone can view cafe_settings" ON public.cafe_settings FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage cafe_settings" ON public.cafe_settings USING (auth.uid() IS NOT NULL);

-- menu_items: Authenticated users can do everything, anyone can SELECT
CREATE POLICY "Anyone can view menu_items" ON public.menu_items FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage menu_items" ON public.menu_items USING (auth.uid() IS NOT NULL);

-- notifications: Authenticated users can do everything, anyone can SELECT
CREATE POLICY "Anyone can view notifications" ON public.notifications FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage notifications" ON public.notifications USING (auth.uid() IS NOT NULL);

-- =============================================================================
-- Performance Indexes
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_loyalty_points ON public.profiles(loyalty_points DESC);
CREATE INDEX IF NOT EXISTS idx_reservations_table_id ON public.reservations(table_id);
CREATE INDEX IF NOT EXISTS idx_reservations_user_id ON public.reservations(user_id);

-- 3. Loyalty Points Trigger

CREATE OR REPLACE FUNCTION public.handle_order_payment_success()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if payment_status changed to 'paid' and user_id is not null
  IF NEW.payment_status = 'paid' AND OLD.payment_status IS DISTINCT FROM 'paid' AND NEW.user_id IS NOT NULL THEN
    -- Increment loyalty points
    UPDATE public.profiles
    SET loyalty_points = loyalty_points + FLOOR(NEW.total_amount / 100)::INT
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_order_payment_success
  AFTER UPDATE OF payment_status ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_order_payment_success();

-- 4. RPC: Merge Guest Orderswtf is tha

CREATE OR REPLACE FUNCTION public.merge_guest_orders(guest_table_id INT, authenticated_user_id UUID)
RETURNS void AS $$
BEGIN
  -- Update orders where user_id is null and matches the table session
  UPDATE public.orders
  SET user_id = authenticated_user_id
  WHERE table_id = guest_table_id AND user_id IS NULL AND status != 'Completed';
  
  -- Update reservations where user_id is null and matches the table session
  UPDATE public.reservations
  SET user_id = authenticated_user_id
  WHERE table_id = guest_table_id AND user_id IS NULL AND status = 'active';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
