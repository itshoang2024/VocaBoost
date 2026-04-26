BEGIN;

-- Add the additional_notes column to the teacher_requests table if it doesn't exist.
ALTER TABLE public.teacher_requests
ADD COLUMN IF NOT EXISTS additional_notes TEXT;

-- Add the school_email column to the teacher_requests table if it doesn't exist.
ALTER TABLE public.teacher_requests
ADD COLUMN IF NOT EXISTS school_email TEXT;

-- Update the migration tracking table.
INSERT INTO schema_migrations (version, description) 
VALUES ('021', 'Add additional_notes and school_email to teacher_requests table')
ON CONFLICT (version) DO NOTHING;

COMMIT;
SET search_path = public, extensions;
