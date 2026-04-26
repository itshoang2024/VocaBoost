-- Migration: Add RPC function to update word_count on vocab_lists
-- Author: VocaBoost Backend Team
-- Date: 2025-07-28

BEGIN;

-- =================================================================
--  FUNCTION: update_list_word_count
--  This function recalculates and updates the 'word_count' for a
--  given vocabulary list. It's designed to be called after
--  words are added or deleted.
-- =================================================================
CREATE OR REPLACE FUNCTION public.update_list_word_count(list_id_param UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Allows the function to modify tables regardless of the caller's RLS policies
AS $$
BEGIN
  UPDATE public.vocab_lists
  SET word_count = (
    SELECT COUNT(*)
    FROM public.vocabulary
    WHERE list_id = list_id_param
  )
  WHERE id = list_id_param;
END;
$$;


-- =================================================================
--  Step 2: Update the migration tracking table
-- =================================================================
INSERT INTO schema_migrations (version, description)
VALUES ('011', 'Add RPC function to update list word count')
ON CONFLICT (version) DO UPDATE SET
    description = 'Add RPC function to update list word count',
    applied_at = NOW();

COMMIT;
SET search_path = public, extensions;
