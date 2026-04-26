-- Performance optimization indexes for vocabulary queries
-- These indexes significantly improve query performance for N+1 query fix

-- Index for vocabulary lookups by list_id and created_by (common filter combination)
CREATE INDEX IF NOT EXISTS idx_vocabulary_list_user 
    ON vocabulary(list_id, created_by);

-- Critical indexes for nested query optimization (fixes N+1 queries)
CREATE INDEX IF NOT EXISTS idx_vocabulary_examples_vocab_id 
    ON vocabulary_examples(vocabulary_id);

CREATE INDEX IF NOT EXISTS idx_word_synonyms_word_id 
    ON word_synonyms(word_id);

-- Index for user word progress queries filtered by next review date
CREATE INDEX IF NOT EXISTS idx_user_word_progress_next_review 
    ON user_word_progress(user_id, next_review_date) 
    WHERE next_review_date IS NOT NULL;

-- Index for in-progress revision sessions (frequently queried)
CREATE INDEX IF NOT EXISTS idx_revision_sessions_in_progress 
    ON revision_sessions(user_id, status) 
    WHERE status = 'in_progress';

-- Index for vocabulary search by definition (requires pg_trgm extension)
-- Note: Commented out as it requires pg_trgm extension
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_vocabulary_definition_search 
--     ON vocabulary USING gin(definition gin_trgm_ops);

-- Index for learner assignments filtered by status and assignment
CREATE INDEX IF NOT EXISTS idx_learner_assignments_status_classroom 
    ON learner_assignments(status, assignment_id);

-- Index for session word results queries
CREATE INDEX IF NOT EXISTS idx_session_word_results_session 
    ON session_word_results(session_id, word_id);

-- Additional performance indexes for common queries
CREATE INDEX IF NOT EXISTS idx_vocabulary_created_at 
    ON vocabulary(list_id, created_at);

CREATE INDEX IF NOT EXISTS idx_vocabulary_term 
    ON vocabulary(term);
SET search_path = public, extensions;
