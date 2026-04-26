-- Migration: Monthly Progress Tracking for Statistics
-- Author: VocaBoost Backend Team
-- Date: 2025-07-29

BEGIN;

-- =================================================================
--  1. Create the Monthly Progress Table
--  This table will store pre-aggregated data for the "Progress Over Time" chart.
-- =================================================================
CREATE TABLE IF NOT EXISTS public.monthly_user_stats (
    user_id UUID NOT NULL,
    month_start_date DATE NOT NULL,
    cumulative_words_mastered INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,

    CONSTRAINT pk_monthly_user_stats PRIMARY KEY (user_id, month_start_date),
    CONSTRAINT fk_monthly_user_stats_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

-- Apply the timestamp trigger for automatic `updated_at` updates.
CREATE TRIGGER set_timestamp_monthly_user_statistics BEFORE UPDATE ON public.monthly_user_stats
    FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


-- =================================================================
--  2. Create the Database Function (RPC) to Update Monthly Progress
--  This function calculates and updates the stats for a specific user and month.
--  It's designed to be called by a scheduled job or after a revision session.
-- =================================================================
CREATE OR REPLACE FUNCTION public.update_monthly_progress(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Allows the function to run with the permissions of the user who defined it.
AS $$
DECLARE
    current_month_start DATE;
    mastered_count INT;
BEGIN
    -- Get the start of the current month.
    current_month_start := date_trunc('month', now())::date;

    -- Calculate the total number of words mastered by the user up to this point.
    -- A word is considered "mastered" if its review interval is 21 days or more.
    SELECT COUNT(DISTINCT word_id)
    INTO mastered_count
    FROM public.user_word_progress
    WHERE user_id = p_user_id
      AND interval_days >= 21;

    -- Insert or update the record for the current month for this user.
    INSERT INTO public.monthly_user_stats (user_id, month_start_date, cumulative_words_mastered)
    VALUES (p_user_id, current_month_start, mastered_count)
    ON CONFLICT (user_id, month_start_date)
    DO UPDATE SET
        cumulative_words_mastered = EXCLUDED.cumulative_words_mastered,
        updated_at = now();
END;
$$;


-- =================================================================
--  3. Update the Migration Tracking Table
-- =================================================================
INSERT INTO schema_migrations (version, description)
VALUES ('018', 'Create monthly_user_stats table and update function for progress tracking')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
