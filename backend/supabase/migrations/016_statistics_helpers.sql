-- Migration: Helper Functions for Statistics Module
-- Author: VocaBoost Backend Team
-- Date: 2025-07-29

BEGIN;

-- =================================================================
--  Function to calculate completion rates for a given set of lists for a user.
--  This is far more efficient than running multiple queries from the application.
-- =================================================================
CREATE OR REPLACE FUNCTION public.get_completion_rates_for_lists(
    p_user_id UUID,
    p_list_ids UUID[]
)
RETURNS TABLE (
    "listId" UUID,
    "listTitle" TEXT,
    "completionRate" REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        vl.id AS "listId",
        vl.title AS "listTitle",
        -- Calculate the completion rate, handling division by zero.
        -- A word is "mastered" if its interval is >= 21 days.
        CASE
            WHEN vl.word_count > 0 THEN
                (
                    SELECT (COUNT(DISTINCT p.word_id)::REAL / vl.word_count) * 100
                    FROM public.user_word_progress p
                    WHERE p.user_id = p_user_id
                      AND p.word_id IN (SELECT id FROM public.vocabulary WHERE list_id = vl.id)
                      AND p.interval_days >= 21
                )
            ELSE 0
        END AS "completionRate"
    FROM
        public.vocab_lists vl
    WHERE
        vl.id = ANY(p_list_ids);
END;
$$;


-- =================================================================
--  Update the Migration Tracking Table
-- =================================================================
INSERT INTO schema_migrations (version, description)
VALUES ('016', 'Create helper function for statistics module')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
