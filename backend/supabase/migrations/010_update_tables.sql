-- Migration: Add translation to words and refactor examples to one-to-one
-- Author: VocaBoost Backend Team
-- Date: 2025-07-28

BEGIN;

-- =================================================================
--  Step 1: Add the 'translation' column to the 'vocabulary' table
-- =================================================================
ALTER TABLE public.vocabulary
ADD COLUMN IF NOT EXISTS translation TEXT;


-- =================================================================
--  Step 2: Refactor the 'vocabulary_examples' table
-- =================================================================

-- 2a: Handle potential duplicates from the old one-to-many structure.
-- We will keep only the MOST RECENT example for each word and delete the others.
DELETE FROM public.vocabulary_examples
WHERE id NOT IN (
    SELECT DISTINCT ON (vocabulary_id) id
    FROM public.vocabulary_examples
    ORDER BY vocabulary_id, created_at DESC
);

-- 2b: Remove the now-redundant 'translation' column from the examples table.
ALTER TABLE public.vocabulary_examples
DROP COLUMN IF EXISTS translation;

-- 2c: Drop the old primary key and the redundant 'id' column.
ALTER TABLE public.vocabulary_examples DROP CONSTRAINT IF EXISTS vocabulary_examples_pkey;
ALTER TABLE public.vocabulary_examples DROP COLUMN IF EXISTS id;

-- 2d: Set the 'vocabulary_id' column as the new primary key.
-- This enforces the one-to-one relationship at the database level.
ALTER TABLE public.vocabulary_examples ADD PRIMARY KEY (vocabulary_id);

-- 2e: Re-apply a foreign key constraint to ensure data integrity.
-- This also ensures that if a word is deleted, its example is deleted too.
ALTER TABLE public.vocabulary_examples DROP CONSTRAINT IF EXISTS fk_vocabulary_examples_vocabulary; -- Drop if it exists from old migrations
ALTER TABLE public.vocabulary_examples
ADD CONSTRAINT fk_vocabulary_examples_vocabulary
FOREIGN KEY (vocabulary_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;


-- =================================================================
--  Step 3: Update the migration tracking table
-- =================================================================
INSERT INTO schema_migrations (version, description)
VALUES ('010', 'Add translation to words and refactor examples to one-to-one')
ON CONFLICT (version) DO UPDATE SET
    description = 'Add translation to words and refactor examples to one-to-one',
    applied_at = NOW();

COMMIT;
SET search_path = public, extensions;
