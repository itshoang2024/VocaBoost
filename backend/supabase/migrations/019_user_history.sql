-- Migration: User Viewing History
-- Author: VocaBoost Backend Team
-- Date: 2025-08-01

BEGIN;

-- Table to track when a user accesses a vocabulary list
CREATE TABLE IF NOT EXISTS public.user_list_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL,
    list_id UUID NOT NULL,
    last_accessed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign key constraints
    CONSTRAINT fk_user_list_history_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_list_history_list FOREIGN KEY (list_id) REFERENCES public.vocab_lists(id) ON DELETE CASCADE,

    -- A user can only have one history entry per list
    UNIQUE (user_id, list_id)
);

-- Index for efficient querying of a user's history
CREATE INDEX IF NOT EXISTS idx_user_list_history_user_accessed ON public.user_list_history(user_id, last_accessed_at DESC);


-- Update the migration tracking table
INSERT INTO schema_migrations (version, description) 
VALUES ('019', 'Create user_list_history table')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
