-- Migration: Popular Lists Feature
-- Author: VocaBoost Backend Team
-- Date: 2025-08-01

BEGIN;

-- Step 1: Add a view_count column to the vocab_lists table
ALTER TABLE public.vocab_lists
ADD COLUMN IF NOT EXISTS view_count INT NOT NULL DEFAULT 0;

-- Step 2: Create a trigger function to increment the view count
CREATE OR REPLACE FUNCTION increment_list_view_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.vocab_lists
    SET view_count = view_count + 1
    WHERE id = NEW.list_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Attach the trigger to the user_list_history table
-- This trigger will fire every time a NEW history record is INSERTED for a user-list pair.
-- It will NOT fire on UPDATE, so a single user viewing the same list multiple times only counts once.
DROP TRIGGER IF EXISTS on_new_list_view ON public.user_list_history;
CREATE TRIGGER on_new_list_view
AFTER INSERT ON public.user_list_history
FOR EACH ROW
EXECUTE FUNCTION increment_list_view_count();


-- Update the migration tracking table
INSERT INTO schema_migrations (version, description) 
VALUES ('020', 'Add view_count and trigger for popular lists')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
