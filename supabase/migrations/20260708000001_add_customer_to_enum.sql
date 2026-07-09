-- Step 1 of 2: Add 'customer' to the user_role enum (must run before Step 2)
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'customer';
