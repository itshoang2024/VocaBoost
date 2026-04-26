-- Migration: Add helper function for revision module

CREATE OR REPLACE FUNCTION get_lists_with_due_words(
    p_user_id UUID,
    p_limit INT,
    p_offset INT
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    word_count INT,
    due_word_count BIGINT,
    tags JSON
) AS $$
BEGIN
    RETURN QUERY
    WITH lists_with_due_counts AS (
        SELECT
            l.id,
            COUNT(uwp.word_id) as due_count
        FROM
            vocab_lists l
        JOIN
            user_word_progress uwp ON l.id = (SELECT v.list_id FROM vocabulary v WHERE v.id = uwp.word_id)
        WHERE
            uwp.user_id = p_user_id
            AND uwp.next_review_date <= NOW()
            AND l.is_active = TRUE
        GROUP BY
            l.id
        HAVING
            COUNT(uwp.word_id) > 0
    )
    SELECT
        vl.id,
        vl.title,
        vl.word_count,
        ldc.due_count,
        (SELECT json_agg(t.name) FROM list_tags lt JOIN tags t ON lt.tag_id = t.id WHERE lt.list_id = vl.id) as tags
    FROM
        vocab_lists vl
    JOIN
        lists_with_due_counts ldc ON vl.id = ldc.id
    ORDER BY
        ldc.due_count DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
SET search_path = public, extensions;
