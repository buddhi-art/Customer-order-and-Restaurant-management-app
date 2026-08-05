-- Staff Table
CREATE TABLE IF NOT EXISTS public.staff (
    id text PRIMARY KEY,
    name text NOT NULL,
    phone text NOT NULL,
    role text NOT NULL,
    current_shift text NOT NULL,
    hourly_wage numeric NOT NULL,
    is_clocked_in boolean NOT NULL DEFAULT false,
    last_clock_in timestamptz,
    joined_at timestamptz NOT NULL DEFAULT now()
);

-- Expenses Table
CREATE TABLE IF NOT EXISTS public.expenses (
    id text PRIMARY KEY,
    title text NOT NULL,
    description text NOT NULL,
    amount numeric NOT NULL,
    category text NOT NULL,
    date timestamptz NOT NULL DEFAULT now(),
    paid_to text NOT NULL
);

-- Feedback Table
CREATE TABLE IF NOT EXISTS public.feedback (
    id text PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id),
    customer_name text NOT NULL,
    rating double precision NOT NULL,
    comment text NOT NULL,
    item_name text,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'staff') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.staff;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'expenses') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.expenses;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'feedback') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.feedback;
    END IF;
END $$;

-- Staff Policies: Admin Only
DROP POLICY IF EXISTS "Admins can manage staff" ON public.staff;
CREATE POLICY "Admins can manage staff" ON public.staff
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- Expenses Policies: Admin Only
DROP POLICY IF EXISTS "Admins can manage expenses" ON public.expenses;
CREATE POLICY "Admins can manage expenses" ON public.expenses
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- Feedback Policies: Auth users insert, Admins read
DROP POLICY IF EXISTS "Users can insert feedback" ON public.feedback;
CREATE POLICY "Users can insert feedback" ON public.feedback
    FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
    );

DROP POLICY IF EXISTS "Admins can read feedback" ON public.feedback;
CREATE POLICY "Admins can read feedback" ON public.feedback
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );
