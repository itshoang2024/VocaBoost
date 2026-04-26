-- Migration: Add word_ids to revision_sessions table
-- Author: VocaBoost Backend Team
-- Date: 2025-07-30

BEGIN;

-- Add a new column to store the specific word IDs for each session
ALTER TABLE public.revision_sessions
ADD COLUMN IF NOT EXISTS word_ids JSONB;

-- Add an index for potentially querying this column in the future
CREATE INDEX IF NOT EXISTS idx_revision_sessions_word_ids ON public.revision_sessions USING GIN (word_ids);

-- Update the migration tracking table
INSERT INTO schema_migrations (version, description) 
VALUES ('013', 'Add word_ids column to revision_sessions table')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
