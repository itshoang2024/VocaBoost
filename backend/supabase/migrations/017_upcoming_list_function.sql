-- Migration: Add functions for upcoming review lists
-- Author: VocaBoost Backend Team
-- Date: 2025-08-02

BEGIN;

-- This function finds upcoming review lists for a user, excluding today's reviews.
CREATE OR REPLACE FUNCTION get_upcoming_review_lists(
    p_user_id UUID,
    p_limit INT,
    p_offset INT
)
RETURNS TABLE (
    "listId" UUID,
    title TEXT,
    "wordCount" INT,
    creator JSON,
    "next_review_in_days" INT
) AS $$
BEGIN
    RETURN QUERY
    WITH list_next_review AS (
        SELECT
            p.list_id,
            MIN(p.next_review_date) as next_review_date
        FROM
            public.user_word_progress p
        WHERE
            p.user_id = p_user_id
            AND p.next_review_date >= (NOW()::DATE + 1) -- From tomorrow
            AND p.next_review_date < (NOW()::DATE + 8)  -- Up to 7 days from now
        GROUP BY
            p.list_id
    )
    SELECT
        vl.id AS "listId",
        vl.title,
        vl.word_count AS "wordCount",
        json_build_object('display_name', u.display_name) AS creator,
        GREATEST(1, DATE_PART('day', lnr.next_review_date - NOW()))::INT AS "next_review_in_days"
    FROM
        public.vocab_lists vl
    JOIN
        list_next_review lnr ON vl.id = lnr.list_id
    LEFT JOIN
        public.users u ON vl.creator_id = u.id
    WHERE
        vl.is_active = TRUE
    ORDER BY
        "next_review_in_days" ASC, vl.updated_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- This function counts the number of lists that have upcoming reviews for pagination.
CREATE OR REPLACE FUNCTION count_distinct_lists_for_user_progress(
    p_user_id UUID
)
RETURNS INT AS $$
BEGIN
    RETURN ( -- <-- CORRECTED: Changed from RETURNS to RETURN
        SELECT COUNT(DISTINCT p.list_id)
        FROM public.user_word_progress p
        WHERE
            p.user_id = p_user_id
            -- Add the same filter here for consistency
            AND p.next_review_date >= (NOW()::DATE + 1)
            AND p.next_review_date < (NOW()::DATE + 8)
    );
END;
$$ LANGUAGE plpgsql;

-- Record the migration
INSERT INTO schema_migrations (version, description) 
VALUES ('017', 'Create functions for upcoming review lists')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
