-- Consolidate duplicate foreign key constraints
-- This migration removes duplicate foreign key constraints that were causing
-- Supabase nested query ambiguity errors

BEGIN;

-- ========================================
-- VOCABULARY_EXAMPLES TABLE FOREIGN KEYS
-- ========================================

-- Drop all existing foreign key constraints for vocabulary_examples
-- These were created in different migrations causing conflicts
ALTER TABLE public.vocabulary_examples DROP CONSTRAINT IF EXISTS fk_vocab_examples_vocabulary CASCADE;
ALTER TABLE public.vocabulary_examples DROP CONSTRAINT IF EXISTS fk_vocabulary_examples_vocabulary CASCADE; 
ALTER TABLE public.vocabulary_examples DROP CONSTRAINT IF EXISTS fk_vocab_examples_vocabulary_delete CASCADE;

-- Add a single, clean foreign key constraint
ALTER TABLE public.vocabulary_examples 
ADD CONSTRAINT fk_vocabulary_examples_vocabulary_id
FOREIGN KEY (vocabulary_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;

-- ========================================
-- WORD_SYNONYMS TABLE FOREIGN KEYS  
-- ========================================

-- Drop all existing foreign key constraints for word_synonyms
ALTER TABLE public.word_synonyms DROP CONSTRAINT IF EXISTS fk_word_synonyms_word CASCADE;
ALTER TABLE public.word_synonyms DROP CONSTRAINT IF EXISTS fk_word_synonyms_word_delete CASCADE;

-- Add a single, clean foreign key constraint
ALTER TABLE public.word_synonyms 
ADD CONSTRAINT fk_word_synonyms_word_id
FOREIGN KEY (word_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;

-- ========================================
-- VERIFICATION QUERIES (for debugging)
-- ========================================

-- Verify the new constraints exist
DO $$ 
BEGIN 
    -- Check if vocabulary_examples constraint exists
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_vocabulary_examples_vocabulary_id'
        AND table_name = 'vocabulary_examples'
    ) THEN 
        RAISE NOTICE 'SUCCESS: vocabulary_examples foreign key constraint created';
    ELSE 
        RAISE EXCEPTION 'FAILED: vocabulary_examples foreign key constraint not found';
    END IF;

    -- Check if word_synonyms constraint exists
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_word_synonyms_word_id'
        AND table_name = 'word_synonyms'
    ) THEN 
        RAISE NOTICE 'SUCCESS: word_synonyms foreign key constraint created';
    ELSE 
        RAISE EXCEPTION 'FAILED: word_synonyms foreign key constraint not found';
    END IF;
END $$;

COMMIT;
SET search_path = public, extensions;
