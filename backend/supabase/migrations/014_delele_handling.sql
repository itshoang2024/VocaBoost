-- For vocabulary_examples
BEGIN;

ALTER TABLE public.vocabulary_examples ADD CONSTRAINT fk_vocab_examples_vocabulary_delete 
    FOREIGN KEY (vocabulary_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;

-- For word_synonyms
ALTER TABLE public.word_synonyms ADD CONSTRAINT fk_word_synonyms_word_delete 
    FOREIGN KEY (word_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;

-- For user_word_progress
ALTER TABLE public.user_word_progress ADD CONSTRAINT fk_user_word_progress_word_delete 
    FOREIGN KEY (word_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;

INSERT INTO schema_migrations (version, description) 
VALUES ('014', 'Delete Handling')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
