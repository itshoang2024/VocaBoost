-- =================================================================
-- VocaBoost Statistics Demo Seed Overlay
-- Purpose: refresh learner statistics data for screenshot/demo sessions.
-- Usage: run after migrations, or after backend/supabase/seed.sql.
-- Demo login created here: learner@vocaboost.com / password
-- =================================================================

BEGIN;

-- -----------------------------------------------------------------
-- Demo learner account
-- -----------------------------------------------------------------
INSERT INTO public.users (
  id,
  email,
  password_hash,
  display_name,
  role,
  account_status,
  email_verified,
  created_at,
  updated_at
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  'learner@vocaboost.com',
  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'Demo Learner',
  'learner',
  'active',
  true,
  NOW() - INTERVAL '90 days',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  display_name = EXCLUDED.display_name,
  role = EXCLUDED.role,
  account_status = EXCLUDED.account_status,
  email_verified = EXCLUDED.email_verified,
  updated_at = NOW();

INSERT INTO public.user_settings (
  user_id,
  daily_goal,
  timezone,
  language,
  theme,
  notification_preferences,
  learning_preferences
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  30,
  'Asia/Ho_Chi_Minh',
  'en',
  'light',
  '{"email": true, "push": true}',
  '{"preferred_methods": ["flashcard", "fill_blank"], "session_length": 20}'
) ON CONFLICT (user_id) DO UPDATE SET
  daily_goal = EXCLUDED.daily_goal,
  timezone = EXCLUDED.timezone,
  language = EXCLUDED.language,
  theme = EXCLUDED.theme,
  notification_preferences = EXCLUDED.notification_preferences,
  learning_preferences = EXCLUDED.learning_preferences,
  updated_at = NOW();

-- -----------------------------------------------------------------
-- Demo lists and words
-- -----------------------------------------------------------------
INSERT INTO public.vocab_lists (
  id,
  creator_id,
  title,
  description,
  word_count,
  privacy_setting,
  is_active,
  created_at,
  updated_at,
  view_count
) VALUES
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'IELTS Academic Sprint', 'Academic vocabulary with examples for IELTS Writing Task 2 and reading passages.', 8, 'public', true, NOW() - INTERVAL '70 days', NOW() - INTERVAL '2 hours', 176),
('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Business Communication Kit', 'Professional terms for meetings, planning, reporting, and workplace collaboration.', 8, 'public', true, NOW() - INTERVAL '55 days', NOW() - INTERVAL '6 hours', 142),
('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Daily Conversation Fluency', 'Practical words for everyday errands, schedules, and casual conversations.', 8, 'private', true, NOW() - INTERVAL '32 days', NOW() - INTERVAL '25 minutes', 61),
('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'Product & Technology English', 'Modern product, software, and startup vocabulary for tech-focused learners.', 8, 'public', true, NOW() - INTERVAL '20 days', NOW() - INTERVAL '1 day', 128)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  word_count = EXCLUDED.word_count,
  privacy_setting = EXCLUDED.privacy_setting,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at,
  view_count = EXCLUDED.view_count;

INSERT INTO public.vocabulary (
  id,
  list_id,
  created_by,
  term,
  definition,
  translation,
  phonetics,
  created_at,
  updated_at
) VALUES
('aaaaaaaa-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'analyze', 'to examine something carefully in order to understand it', 'phan tich', '/AN-uh-lyze/', NOW() - INTERVAL '70 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'coherent', 'logical and easy to understand', 'mach lac', '/koh-HEER-uhnt/', NOW() - INTERVAL '70 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'substantial', 'large in amount, value, or importance', 'dang ke', '/sub-STAN-shuhl/', NOW() - INTERVAL '69 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'perspective', 'a particular way of thinking about something', 'goc nhin', '/per-SPEK-tiv/', NOW() - INTERVAL '69 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000005', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'stakeholder', 'a person or group affected by a decision or project', 'ben lien quan', '/STAYK-hohl-der/', NOW() - INTERVAL '55 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000006', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'deadline', 'the latest time by which something must be finished', 'han chot', '/DED-lyne/', NOW() - INTERVAL '55 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000007', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'workflow', 'the sequence of steps used to complete work', 'quy trinh lam viec', '/WERK-flow/', NOW() - INTERVAL '54 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000008', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'negotiate', 'to discuss terms in order to reach an agreement', 'dam phan', '/nuh-GOH-shee-ayt/', NOW() - INTERVAL '54 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000009', '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'errand', 'a short trip to do a practical task', 'viec vat', '/AIR-uhnd/', NOW() - INTERVAL '32 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000010', '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'commute', 'to travel regularly between home and work or school', 'di lai hang ngay', '/kuh-MYOOT/', NOW() - INTERVAL '32 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000011', '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'appointment', 'an arrangement to meet someone at a specific time', 'cuoc hen', '/uh-POINT-muhnt/', NOW() - INTERVAL '31 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000012', '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'routine', 'a usual sequence of actions', 'thoi quen', '/roo-TEEN/', NOW() - INTERVAL '31 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000013', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'prototype', 'an early model used to test an idea', 'ban mau', '/PROH-tuh-type/', NOW() - INTERVAL '20 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000014', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'iteration', 'one version or cycle of improvement', 'lan lap', '/it-uh-RAY-shuhn/', NOW() - INTERVAL '20 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000015', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'scalable', 'able to grow without losing performance', 'co the mo rong', '/SKAY-luh-buhl/', NOW() - INTERVAL '19 days', NOW()),
('aaaaaaaa-0000-0000-0000-000000000016', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'deploy', 'to release software so people can use it', 'trien khai', '/di-PLOY/', NOW() - INTERVAL '19 days', NOW())
ON CONFLICT (id) DO UPDATE SET
  term = EXCLUDED.term,
  definition = EXCLUDED.definition,
  translation = EXCLUDED.translation,
  phonetics = EXCLUDED.phonetics,
  updated_at = NOW();

INSERT INTO public.vocabulary_examples (vocabulary_id, example_sentence, ai_generated, generation_prompt) VALUES
('aaaaaaaa-0000-0000-0000-000000000001', 'The essay analyzes how urban design affects daily commuting habits.', false, NULL),
('aaaaaaaa-0000-0000-0000-000000000002', 'Her presentation was coherent because every point supported the main argument.', false, NULL),
('aaaaaaaa-0000-0000-0000-000000000005', 'The project manager asked each stakeholder to approve the timeline.', false, NULL),
('aaaaaaaa-0000-0000-0000-000000000006', 'We moved the deadline to Friday so the team could finish testing.', false, NULL),
('aaaaaaaa-0000-0000-0000-000000000009', 'I need to run one errand before joining the study session.', false, NULL),
('aaaaaaaa-0000-0000-0000-000000000013', 'The prototype helped the team test the new vocabulary review flow.', false, NULL),
('aaaaaaaa-0000-0000-0000-000000000015', 'A scalable backend can support more classrooms during exam season.', false, NULL),
('aaaaaaaa-0000-0000-0000-000000000016', 'The team will deploy the frontend after checking the production API URL.', false, NULL)
ON CONFLICT (vocabulary_id) DO UPDATE SET
  example_sentence = EXCLUDED.example_sentence,
  ai_generated = EXCLUDED.ai_generated,
  generation_prompt = EXCLUDED.generation_prompt,
  created_at = NOW();

UPDATE public.vocab_lists
SET word_count = (
  SELECT COUNT(*)
  FROM public.vocabulary
  WHERE vocabulary.list_id = vocab_lists.id
)
WHERE creator_id = '11111111-1111-1111-1111-111111111111';

-- -----------------------------------------------------------------
-- Dashboard history, due reviews, and completion data
-- -----------------------------------------------------------------
INSERT INTO public.user_list_history (user_id, list_id, last_accessed_at) VALUES
('11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '10 minutes'),
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '1 hour'),
('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '5 hours'),
('11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', NOW() - INTERVAL '1 day')
ON CONFLICT (user_id, list_id) DO UPDATE SET
  last_accessed_at = EXCLUDED.last_accessed_at;

INSERT INTO public.user_word_progress (
  user_id,
  word_id,
  next_review_date,
  interval_days,
  ease_factor,
  repetitions,
  correct_count,
  incorrect_count,
  last_reviewed_at,
  review_context
) VALUES
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001', NOW() - INTERVAL '3 hours', 24, 2.85, 7, 12, 1, NOW() - INTERVAL '7 days', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000002', NOW() - INTERVAL '2 hours', 18, 2.55, 5, 9, 2, NOW() - INTERVAL '5 days', 'fill_blank'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000003', CURRENT_DATE + INTERVAL '1 day' + INTERVAL '9 hours', 12, 2.45, 4, 7, 1, NOW() - INTERVAL '3 days', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000004', CURRENT_DATE + INTERVAL '3 days' + INTERVAL '10 hours', 30, 3.05, 8, 14, 1, NOW() - INTERVAL '10 days', 'fill_blank'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000005', NOW() - INTERVAL '1 hour', 21, 2.75, 6, 11, 1, NOW() - INTERVAL '6 days', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', NOW() - INTERVAL '35 minutes', 9, 2.30, 3, 5, 2, NOW() - INTERVAL '2 days', 'fill_blank'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000007', CURRENT_DATE + INTERVAL '2 days' + INTERVAL '11 hours', 15, 2.50, 5, 8, 1, NOW() - INTERVAL '4 days', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000008', CURRENT_DATE + INTERVAL '6 days' + INTERVAL '8 hours', 28, 2.90, 7, 12, 0, NOW() - INTERVAL '9 days', 'fill_blank'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000009', NOW() - INTERVAL '20 minutes', 6, 2.20, 2, 4, 2, NOW() - INTERVAL '1 day', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000010', NOW() - INTERVAL '15 minutes', 4, 2.10, 2, 3, 2, NOW() - INTERVAL '1 day', 'fill_blank'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000011', CURRENT_DATE + INTERVAL '1 day' + INTERVAL '14 hours', 3, 2.25, 2, 4, 1, NOW() - INTERVAL '1 day', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000012', CURRENT_DATE + INTERVAL '4 days' + INTERVAL '9 hours', 22, 2.80, 6, 10, 1, NOW() - INTERVAL '7 days', 'fill_blank'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000013', NOW() - INTERVAL '50 minutes', 5, 2.20, 2, 4, 2, NOW() - INTERVAL '1 day', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000014', CURRENT_DATE + INTERVAL '2 days' + INTERVAL '9 hours', 11, 2.45, 4, 7, 1, NOW() - INTERVAL '3 days', 'fill_blank'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000015', CURRENT_DATE + INTERVAL '5 days' + INTERVAL '10 hours', 26, 2.95, 7, 13, 0, NOW() - INTERVAL '8 days', 'flashcard'),
('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000016', NOW() - INTERVAL '5 minutes', 2, 2.15, 1, 2, 2, NOW() - INTERVAL '12 hours', 'fill_blank')
ON CONFLICT (user_id, word_id) DO UPDATE SET
  next_review_date = EXCLUDED.next_review_date,
  interval_days = EXCLUDED.interval_days,
  ease_factor = EXCLUDED.ease_factor,
  repetitions = EXCLUDED.repetitions,
  correct_count = EXCLUDED.correct_count,
  incorrect_count = EXCLUDED.incorrect_count,
  last_reviewed_at = EXCLUDED.last_reviewed_at,
  review_context = EXCLUDED.review_context,
  updated_at = NOW();

-- -----------------------------------------------------------------
-- Learner statistics charts
-- -----------------------------------------------------------------
INSERT INTO public.user_stats (
  user_id,
  total_vocabulary,
  total_reviews,
  correct_reviews,
  current_streak,
  longest_streak,
  last_review_date,
  total_study_time,
  updated_at
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  146,
  512,
  448,
  16,
  31,
  CURRENT_DATE,
  2130,
  NOW()
) ON CONFLICT (user_id) DO UPDATE SET
  total_vocabulary = EXCLUDED.total_vocabulary,
  total_reviews = EXCLUDED.total_reviews,
  correct_reviews = EXCLUDED.correct_reviews,
  current_streak = EXCLUDED.current_streak,
  longest_streak = EXCLUDED.longest_streak,
  last_review_date = EXCLUDED.last_review_date,
  total_study_time = EXCLUDED.total_study_time,
  updated_at = NOW();

INSERT INTO public.monthly_user_stats (user_id, month_start_date, cumulative_words_mastered) VALUES
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE - INTERVAL '7 months')::date, 18),
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE - INTERVAL '6 months')::date, 31),
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE - INTERVAL '5 months')::date, 49),
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE - INTERVAL '4 months')::date, 73),
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE - INTERVAL '3 months')::date, 95),
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE - INTERVAL '2 months')::date, 118),
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date, 132),
('11111111-1111-1111-1111-111111111111', date_trunc('month', CURRENT_DATE)::date, 146)
ON CONFLICT (user_id, month_start_date) DO UPDATE SET
  cumulative_words_mastered = EXCLUDED.cumulative_words_mastered,
  updated_at = NOW();

INSERT INTO public.revision_sessions (
  id,
  user_id,
  vocab_list_id,
  session_type,
  status,
  started_at,
  completed_at,
  score,
  total_words,
  correct_answers,
  word_ids
) VALUES
('bbbbbbbb-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', 'flashcard', 'completed', NOW() - INTERVAL '1 day' - INTERVAL '30 minutes', NOW() - INTERVAL '1 day' - INTERVAL '12 minutes', 95, 4, 4, '["aaaaaaaa-0000-0000-0000-000000000009", "aaaaaaaa-0000-0000-0000-000000000010", "aaaaaaaa-0000-0000-0000-000000000011", "aaaaaaaa-0000-0000-0000-000000000012"]'::jsonb),
('bbbbbbbb-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'fill_blank', 'completed', NOW() - INTERVAL '3 days' - INTERVAL '35 minutes', NOW() - INTERVAL '3 days' - INTERVAL '14 minutes', 88, 4, 4, '["aaaaaaaa-0000-0000-0000-000000000001", "aaaaaaaa-0000-0000-0000-000000000002", "aaaaaaaa-0000-0000-0000-000000000003", "aaaaaaaa-0000-0000-0000-000000000004"]'::jsonb),
('bbbbbbbb-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'flashcard', 'completed', NOW() - INTERVAL '5 days' - INTERVAL '25 minutes', NOW() - INTERVAL '5 days' - INTERVAL '9 minutes', 91, 4, 4, '["aaaaaaaa-0000-0000-0000-000000000005", "aaaaaaaa-0000-0000-0000-000000000006", "aaaaaaaa-0000-0000-0000-000000000007", "aaaaaaaa-0000-0000-0000-000000000008"]'::jsonb),
('bbbbbbbb-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'fill_blank', 'completed', NOW() - INTERVAL '8 days' - INTERVAL '32 minutes', NOW() - INTERVAL '8 days' - INTERVAL '11 minutes', 84, 4, 3, '["aaaaaaaa-0000-0000-0000-000000000013", "aaaaaaaa-0000-0000-0000-000000000014", "aaaaaaaa-0000-0000-0000-000000000015", "aaaaaaaa-0000-0000-0000-000000000016"]'::jsonb),
('bbbbbbbb-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', 'flashcard', 'completed', NOW() - INTERVAL '13 days' - INTERVAL '29 minutes', NOW() - INTERVAL '13 days' - INTERVAL '13 minutes', 90, 2, 2, '["aaaaaaaa-0000-0000-0000-000000000009", "aaaaaaaa-0000-0000-0000-000000000010"]'::jsonb),
('bbbbbbbb-0000-0000-0000-000000000006', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'fill_blank', 'completed', NOW() - INTERVAL '21 days' - INTERVAL '40 minutes', NOW() - INTERVAL '21 days' - INTERVAL '15 minutes', 86, 2, 2, '["aaaaaaaa-0000-0000-0000-000000000001", "aaaaaaaa-0000-0000-0000-000000000002"]'::jsonb),
('bbbbbbbb-0000-0000-0000-000000000007', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'flashcard', 'completed', NOW() - INTERVAL '34 days' - INTERVAL '28 minutes', NOW() - INTERVAL '34 days' - INTERVAL '8 minutes', 93, 2, 2, '["aaaaaaaa-0000-0000-0000-000000000005", "aaaaaaaa-0000-0000-0000-000000000006"]'::jsonb),
('bbbbbbbb-0000-0000-0000-000000000008', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'fill_blank', 'completed', NOW() - INTERVAL '55 days' - INTERVAL '31 minutes', NOW() - INTERVAL '55 days' - INTERVAL '10 minutes', 87, 2, 2, '["aaaaaaaa-0000-0000-0000-000000000013", "aaaaaaaa-0000-0000-0000-000000000014"]'::jsonb)
ON CONFLICT (id) DO UPDATE SET
  started_at = EXCLUDED.started_at,
  completed_at = EXCLUDED.completed_at,
  score = EXCLUDED.score,
  total_words = EXCLUDED.total_words,
  correct_answers = EXCLUDED.correct_answers,
  status = EXCLUDED.status,
  word_ids = EXCLUDED.word_ids;

COMMIT;

-- Quick manual checks:
-- SELECT email, display_name FROM public.users WHERE id = '11111111-1111-1111-1111-111111111111';
-- SELECT title, word_count, view_count FROM public.vocab_lists WHERE creator_id = '11111111-1111-1111-1111-111111111111';
-- SELECT COUNT(*) FROM public.user_word_progress WHERE user_id = '11111111-1111-1111-1111-111111111111' AND next_review_date <= NOW();
-- SELECT * FROM public.user_stats WHERE user_id = '11111111-1111-1111-1111-111111111111';
