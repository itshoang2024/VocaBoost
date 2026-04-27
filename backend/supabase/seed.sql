-- =================================================================
-- VocaBoost Seed Data
-- Author: VocaBoost Development Team
-- Purpose: Sample data for development and testing
-- Usage: supabase db reset --seed
-- =================================================================

BEGIN;

-- Disable triggers during seeding to avoid conflicts
SET session_replication_role = replica;

-- =================================================================
-- CLEAR EXISTING DATA (in correct order due to foreign keys)
-- =================================================================
TRUNCATE TABLE 
  achievements,
  notifications,
  audit_logs,
  reports,
  monthly_user_stats,
  user_list_history,
  assignment_sublists,
  learner_assignments,
  assignments,
  classroom_invitations,
  classroom_members,
  classrooms,
  session_word_results,
  revision_sessions,
  user_word_progress,
  ai_generations,
  list_tags,
  word_synonyms,
  vocabulary_examples,
  vocabulary,
  vocab_lists,
  tags,
  teacher_requests,
  auth_tokens,
  user_stats,
  user_settings,
  user_deactivation,
  users
RESTART IDENTITY CASCADE;

-- =================================================================
-- USERS DATA
-- =================================================================
INSERT INTO users (id, email, password_hash, display_name, role, account_status, email_verified, created_at) VALUES
-- Admin
('00000000-0000-0000-0000-000000000001', 'admin@vocaboost.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System Admin', 'admin', 'active', true, '2024-01-01 00:00:00+00'),

-- Teachers
('00000000-0000-0000-0000-000000000002', 'teacher1@vocaboost.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ms. Sarah Johnson', 'teacher', 'active', true, '2024-01-02 08:00:00+00'),
('00000000-0000-0000-0000-000000000003', 'teacher2@vocaboost.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mr. David Chen', 'teacher', 'active', true, '2024-01-03 09:00:00+00'),
('00000000-0000-0000-0000-000000000004', 'newteacher@vocaboost.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ms. Emily Garcia', 'teacher', 'pending_verification', false, '2024-07-25 10:00:00+00'),

-- Learners
('00000000-0000-0000-0000-000000000011', 'student1@email.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Alex Nguyen', 'learner', 'active', true, '2024-02-01 10:00:00+00'),
('00000000-0000-0000-0000-000000000012', 'student2@email.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Maria Rodriguez', 'learner', 'active', true, '2024-02-02 11:00:00+00'),
('00000000-0000-0000-0000-000000000013', 'student3@email.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'John Smith', 'learner', 'active', true, '2024-02-03 12:00:00+00'),
('00000000-0000-0000-0000-000000000014', 'student4@email.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Lisa Wang', 'learner', 'active', true, '2024-02-04 13:00:00+00'),
('00000000-0000-0000-0000-000000000015', 'student5@email.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Michael Brown', 'learner', 'active', true, '2024-02-05 14:00:00+00'),

-- Google OAuth user
('00000000-0000-0000-0000-000000000016', 'googleuser@gmail.com', NULL, 'Google User', 'learner', 'active', true, '2024-03-01 15:00:00+00');

-- Update Google OAuth user
UPDATE users SET google_id = 'google_id_123456789' WHERE id = '00000000-0000-0000-0000-000000000016';

-- =================================================================
-- USER SETTINGS
-- =================================================================
INSERT INTO user_settings (user_id, daily_goal, timezone, language, theme, notification_preferences, learning_preferences) VALUES
('00000000-0000-0000-0000-000000000001', 20, 'Asia/Ho_Chi_Minh', 'en', 'dark', '{"email": true, "push": false}', '{"preferred_methods": ["flashcard", "fill_blank"], "session_length": 25}'),
('00000000-0000-0000-0000-000000000002', 15, 'Asia/Ho_Chi_Minh', 'en', 'light', '{"email": true, "push": true}', '{"preferred_methods": ["flashcard"], "session_length": 20}'),
('00000000-0000-0000-0000-000000000003', 25, 'America/New_York', 'en', 'light', '{"email": true, "push": false}', '{"preferred_methods": ["word_association"], "session_length": 30}'),
('00000000-0000-0000-0000-000000000011', 10, 'Asia/Ho_Chi_Minh', 'vi', 'light', '{"email": true, "push": true}', '{"preferred_methods": ["flashcard"], "session_length": 15}'),
('00000000-0000-0000-0000-000000000012', 12, 'Asia/Ho_Chi_Minh', 'vi', 'dark', '{"email": false, "push": true}', '{"preferred_methods": ["fill_blank"], "session_length": 20}'),
('00000000-0000-0000-0000-000000000013', 8, 'Europe/London', 'en', 'light', '{"email": true, "push": false}', '{"preferred_methods": ["flashcard", "word_association"], "session_length": 10}'),
('00000000-0000-0000-0000-000000000014', 15, 'Asia/Tokyo', 'en', 'dark', '{"email": true, "push": true}', '{"preferred_methods": ["flashcard"], "session_length": 20}'),
('00000000-0000-0000-0000-000000000015', 18, 'Australia/Sydney', 'en', 'light', '{"email": false, "push": false}', '{"preferred_methods": ["fill_blank"], "session_length": 25}'),
('00000000-0000-0000-0000-000000000016', 10, 'Asia/Ho_Chi_Minh', 'vi', 'light', '{"email": true, "push": true}', '{"preferred_methods": ["flashcard"], "session_length": 20}');

-- =================================================================
-- USER STATS
-- =================================================================
INSERT INTO user_stats (user_id, total_vocabulary, total_reviews, correct_reviews, current_streak, longest_streak, last_review_date, total_study_time) VALUES
('00000000-0000-0000-0000-000000000001', 150, 500, 425, 7, 15, '2024-07-30', 1200),
('00000000-0000-0000-0000-000000000002', 200, 300, 270, 5, 12, '2024-07-29', 800),
('00000000-0000-0000-0000-000000000003', 180, 400, 350, 10, 18, '2024-07-30', 1000),
('00000000-0000-0000-0000-000000000011', 75, 150, 120, 3, 8, '2024-07-30', 350),
('00000000-0000-0000-0000-000000000012', 92, 200, 180, 5, 10, '2024-07-29', 450),
('00000000-0000-0000-0000-000000000013', 45, 80, 65, 2, 5, '2024-07-28', 200),
('00000000-0000-0000-0000-000000000014', 110, 250, 200, 6, 12, '2024-07-30', 600),
('00000000-0000-0000-0000-000000000015', 85, 180, 150, 4, 7, '2024-07-29', 400),
('00000000-0000-0000-0000-000000000016', 25, 50, 40, 1, 3, '2024-07-27', 120);

-- =================================================================
-- TEACHER REQUESTS
-- =================================================================
INSERT INTO teacher_requests (id, user_id, institution, credentials_url, status, created_at) VALUES
('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'International School of Ho Chi Minh City', 'https://example.com/teacher1-cert.pdf', 'approved', '2024-01-02 08:30:00+00'),
('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'Vietnam National University', 'https://example.com/teacher2-cert.pdf', 'approved', '2024-01-03 09:30:00+00'),
('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', 'ABC Language Center', 'https://example.com/teacher3-cert.pdf', 'pending', '2024-07-25 10:30:00+00');

-- =================================================================
-- TAGS
-- =================================================================
INSERT INTO tags (id, name, color) VALUES
(1, 'TOEFL', '#FF6B6B'),
(2, 'IELTS', '#4ECDC4'),
(3, 'Business English', '#45B7D1'),
(4, 'Academic', '#96CEB4'),
(5, 'Daily Conversation', '#FECA57'),
(6, 'Medical', '#FF9FF3'),
(7, 'Technology', '#54A0FF'),
(8, 'Travel', '#5F27CD'),
(9, 'Food & Cooking', '#00D2D3'),
(10, 'Sports', '#FF9F43'),
(11, 'Elementary', '#A55EEA'),
(12, 'Intermediate', '#26de81'),
(13, 'Advanced', '#fd79a8'),
(14, 'Beginner', '#74b9ff'),
(15, 'GRE', '#e17055');

-- =================================================================
-- VOCABULARY LISTS
-- =================================================================
INSERT INTO vocab_lists (id, creator_id, title, description, word_count, privacy_setting, is_active, created_at, updated_at) VALUES
-- Teacher 1's lists
('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'TOEFL Essential Vocabulary', 'Essential words for TOEFL preparation focusing on academic contexts', 20, 'public', true, '2024-03-01 08:00:00+00', '2024-07-15 10:00:00+00'),
('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'Business English Fundamentals', 'Key vocabulary for professional communication', 15, 'public', true, '2024-03-15 09:00:00+00', '2024-07-20 11:00:00+00'),
('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'Advanced Academic Writing', 'Sophisticated vocabulary for academic essays and research', 12, 'private', true, '2024-04-01 10:00:00+00', '2024-07-25 12:00:00+00'),

-- Teacher 2's lists
('20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'IELTS Speaking Vocabulary', 'Common words and phrases for IELTS speaking section', 18, 'public', true, '2024-03-10 08:30:00+00', '2024-07-18 09:30:00+00'),
('20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'Technology Terms', 'Modern technology vocabulary for intermediate learners', 25, 'public', true, '2024-04-05 11:00:00+00', '2024-07-22 14:00:00+00'),

-- Student lists
('20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'My Daily English', 'Personal collection of useful daily words', 10, 'private', true, '2024-05-01 15:00:00+00', '2024-07-28 16:00:00+00'),
('20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'Travel Essentials', 'Must-know words for traveling', 8, 'public', true, '2024-05-15 16:00:00+00', '2024-07-29 17:00:00+00'),

-- Mixed level lists
('20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'Food & Cooking', 'Culinary vocabulary for food enthusiasts', 14, 'public', true, '2024-06-01 12:00:00+00', '2024-07-30 13:00:00+00');

-- =================================================================
-- LIST TAGS ASSOCIATIONS
-- =================================================================
INSERT INTO list_tags (list_id, tag_id) VALUES
-- TOEFL Essential Vocabulary
('20000000-0000-0000-0000-000000000001', 1), -- TOEFL
('20000000-0000-0000-0000-000000000001', 4), -- Academic
('20000000-0000-0000-0000-000000000001', 12), -- Intermediate

-- Business English Fundamentals  
('20000000-0000-0000-0000-000000000002', 3), -- Business English
('20000000-0000-0000-0000-000000000002', 12), -- Intermediate

-- Advanced Academic Writing
('20000000-0000-0000-0000-000000000003', 4), -- Academic
('20000000-0000-0000-0000-000000000003', 13), -- Advanced

-- IELTS Speaking Vocabulary
('20000000-0000-0000-0000-000000000004', 2), -- IELTS
('20000000-0000-0000-0000-000000000004', 5), -- Daily Conversation
('20000000-0000-0000-0000-000000000004', 12), -- Intermediate

-- Technology Terms
('20000000-0000-0000-0000-000000000005', 7), -- Technology
('20000000-0000-0000-0000-000000000005', 12), -- Intermediate

-- My Daily English
('20000000-0000-0000-0000-000000000006', 5), -- Daily Conversation
('20000000-0000-0000-0000-000000000006', 11), -- Elementary

-- Travel Essentials
('20000000-0000-0000-0000-000000000007', 8), -- Travel
('20000000-0000-0000-0000-000000000007', 11), -- Elementary

-- Food & Cooking
('20000000-0000-0000-0000-000000000008', 9), -- Food & Cooking
('20000000-0000-0000-0000-000000000008', 12); -- Intermediate

-- =================================================================
-- VOCABULARY WORDS
-- =================================================================

-- TOEFL Essential Vocabulary (20 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'abundant', 'existing or available in large quantities; plentiful', 'dồi dào, phong phú', '/əˈbʌndənt/', '2024-03-01 08:15:00+00'),
('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'analyze', 'examine methodically and in detail for purposes of explanation and interpretation', 'phân tích', '/ˈænəlaɪz/', '2024-03-01 08:16:00+00'),
('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'coherent', 'logical and consistent; forming a unified whole', 'mạch lạc, có logic', '/koʊˈhɪrənt/', '2024-03-01 08:17:00+00'),
('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'comprehensive', 'complete and including everything that is necessary', 'toàn diện, bao quát', '/ˌkɑːmprɪˈhensɪv/', '2024-03-01 08:18:00+00'),
('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'demonstrate', 'clearly show the existence or truth of something by giving proof or evidence', 'chứng minh, thể hiện', '/ˈdemənstreɪt/', '2024-03-01 08:19:00+00'),
('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'elaborate', 'involving many carefully arranged parts or details; detailed and complicated in design and planning', 'tinh vi, chi tiết', '/ɪˈlæbərət/', '2024-03-01 08:20:00+00'),
('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'facilitate', 'make an action or process easier or help bring about', 'tạo điều kiện thuận lợi', '/fəˈsɪlɪteɪt/', '2024-03-01 08:21:00+00'),
('30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'hypothesis', 'a supposition or proposed explanation made on the basis of limited evidence', 'giả thuyết', '/haɪˈpɑːθəsɪs/', '2024-03-01 08:22:00+00'),
('30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'inevitable', 'certain to happen; unavoidable', 'không thể tránh khỏi', '/ɪnˈevɪtəbl/', '2024-03-01 08:23:00+00'),
('30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'justify', 'show or prove to be right or reasonable', 'biện minh, chứng minh', '/ˈdʒʌstɪfaɪ/', '2024-03-01 08:24:00+00'),
('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'legitimate', 'conforming to the law or to rules; able to be defended with logic or justification', 'hợp pháp, chính đáng', '/lɪˈdʒɪtɪmət/', '2024-03-01 08:25:00+00'),
('30000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'methodology', 'a system of methods used in a particular area of study or activity', 'phương pháp luận', '/ˌmeθəˈdɑːlədʒi/', '2024-03-01 08:26:00+00'),
('30000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'objective', 'not influenced by personal feelings or opinions in considering and representing facts', 'khách quan', '/əbˈdʒektɪv/', '2024-03-01 08:27:00+00'),
('30000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'phenomenon', 'a fact or situation that is observed to exist or happen', 'hiện tượng', '/fəˈnɑːmɪnən/', '2024-03-01 08:28:00+00'),
('30000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'prevalent', 'widespread in a particular area at a particular time', 'phổ biến, thịnh hành', '/ˈprevələnt/', '2024-03-01 08:29:00+00'),
('30000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'subsequent', 'coming after something in time; following', 'tiếp theo, sau đó', '/ˈsʌbsɪkwənt/', '2024-03-01 08:30:00+00'),
('30000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'significant', 'sufficiently great or important to be worthy of attention; noteworthy', 'đáng kể, quan trọng', '/sɪɡˈnɪfɪkənt/', '2024-03-01 08:31:00+00'),
('30000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'theoretical', 'concerned with or involving the theory of a subject or area of study rather than its practical application', 'lý thuyết', '/ˌθiːəˈretɪkl/', '2024-03-01 08:32:00+00'),
('30000000-0000-0000-0000-000000000019', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'valid', 'having a sound basis in logic or fact; reasonable or cogent', 'hợp lệ, có căn cứ', '/ˈvælɪd/', '2024-03-01 08:33:00+00'),
('30000000-0000-0000-0000-000000000020', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'thereby', 'by that means; as a result of that', 'do đó, bằng cách đó', '/ˌðerˈbaɪ/', '2024-03-01 08:34:00+00');

-- Business English Fundamentals (15 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000021', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'agenda', 'a list of items to be discussed at a formal meeting', 'chương trình nghị sự', '/əˈdʒendə/', '2024-03-15 09:15:00+00'),
('30000000-0000-0000-0000-000000000022', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'collaborate', 'work jointly on an activity, especially to produce or create something', 'hợp tác', '/kəˈlæbəreɪt/', '2024-03-15 09:16:00+00'),
('30000000-0000-0000-0000-000000000023', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'deadline', 'the latest time or date by which something should be completed', 'hạn chót', '/ˈdedlaɪn/', '2024-03-15 09:17:00+00'),
('30000000-0000-0000-0000-000000000024', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'efficiency', 'the state or quality of being efficient', 'hiệu quả', '/ɪˈfɪʃənsi/', '2024-03-15 09:18:00+00'),
('30000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'feedback', 'information about reactions to a product, service, or process', 'phản hồi', '/ˈfiːdbæk/', '2024-03-15 09:19:00+00'),
('30000000-0000-0000-0000-000000000026', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'implement', 'put a decision or plan into effect', 'thực hiện', '/ˈɪmplɪment/', '2024-03-15 09:20:00+00'),
('30000000-0000-0000-0000-000000000027', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'negotiate', 'discuss something with someone in order to reach an agreement', 'đàm phán', '/nɪˈɡoʊʃieɪt/', '2024-03-15 09:21:00+00'),
('30000000-0000-0000-0000-000000000028', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'proposal', 'a plan or suggestion put forward for consideration', 'đề xuất', '/prəˈpoʊzl/', '2024-03-15 09:22:00+00'),
('30000000-0000-0000-0000-000000000029', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'revenue', 'income, especially when of a company or organization', 'doanh thu', '/ˈrevəˌnu/', '2024-03-15 09:23:00+00'),
('30000000-0000-0000-0000-000000000030', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'stakeholder', 'a person with an interest or concern in something', 'bên liên quan', '/ˈsteɪkˌhoʊldər/', '2024-03-15 09:24:00+00'),
('30000000-0000-0000-0000-000000000031', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'strategy', 'a plan of action designed to achieve a long-term aim', 'chiến lược', '/ˈstrætədʒi/', '2024-03-15 09:25:00+00'),
('30000000-0000-0000-0000-000000000032', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'budget', 'an estimate of income and expenditure for a set period', 'ngân sách', '/ˈbʌdʒɪt/', '2024-03-15 09:26:00+00'),
('30000000-0000-0000-0000-000000000033', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'quarterly', 'produced or occurring once every three months', 'hàng quý', '/ˈkwɔːrtərli/', '2024-03-15 09:27:00+00'),
('30000000-0000-0000-0000-000000000034', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'merger', 'a combination of two things, especially companies, into one', 'sáp nhập', '/ˈmɜːrdʒər/', '2024-03-15 09:28:00+00'),
('30000000-0000-0000-0000-000000000035', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'portfolio', 'a range of investments held by a person or organization', 'danh mục đầu tư', '/pɔːrtˈfoʊlioʊ/', '2024-03-15 09:29:00+00');

-- Advanced Academic Writing (12 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000036', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'paradigm', 'a typical example or pattern of something', 'mô hình, quan niệm', '/ˈpærədaɪm/', '2024-04-01 10:15:00+00'),
('30000000-0000-0000-0000-000000000037', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'scrutinize', 'examine or inspect closely and thoroughly', 'xem xét kỹ lưỡng', '/ˈskruːtənaɪz/', '2024-04-01 10:16:00+00'),
('30000000-0000-0000-0000-000000000038', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'substantiate', 'provide evidence to support or prove the truth of', 'chứng thực', '/səbˈstænʃieɪt/', '2024-04-01 10:17:00+00'),
('30000000-0000-0000-0000-000000000039', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'discrepancy', 'a lack of compatibility or similarity between two or more facts', 'sự khác biệt', '/dɪsˈkrepənsi/', '2024-04-01 10:18:00+00'),
('30000000-0000-0000-0000-000000000040', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'empirical', 'based on, concerned with, or verifiable by observation or experience', 'thực nghiệm', '/ɪmˈpɪrɪkl/', '2024-04-01 10:19:00+00'),
('30000000-0000-0000-0000-000000000041', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'heuristic', 'enabling a person to discover or learn something for themselves', 'khám phá', '/hjʊˈrɪstɪk/', '2024-04-01 10:20:00+00'),
('30000000-0000-0000-0000-000000000042', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'juxtapose', 'place or deal with close together for contrasting effect', 'đặt cạnh nhau', '/ˌdʒʌkstəˈpoʊz/', '2024-04-01 10:21:00+00'),
('30000000-0000-0000-0000-000000000043', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'pervasive', 'spreading widely throughout an area or a group of people', 'lan rộng', '/pərˈveɪsɪv/', '2024-04-01 10:22:00+00'),
('30000000-0000-0000-0000-000000000044', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'quintessential', 'representing the most perfect example of a quality', 'tinh túy nhất', '/ˌkwɪntɪˈsenʃl/', '2024-04-01 10:23:00+00'),
('30000000-0000-0000-0000-000000000045', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'ubiquitous', 'present, appearing, or found everywhere', 'có mặt khắp nơi', '/juːˈbɪkwɪtəs/', '2024-04-01 10:24:00+00'),
('30000000-0000-0000-0000-000000000046', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'dichotomy', 'a division or contrast between two things', 'sự đối lập', '/daɪˈkɑːtəmi/', '2024-04-01 10:25:00+00'),
('30000000-0000-0000-0000-000000000047', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'synthesis', 'the combination of ideas to form a theory or system', 'tổng hợp', '/ˈsɪnθəsɪs/', '2024-04-01 10:26:00+00');

-- IELTS Speaking Vocabulary (18 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000048', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'outstanding', 'exceptionally good; clearly noticeable', 'xuất sắc', '/aʊtˈstændɪŋ/', '2024-03-10 08:45:00+00'),
('30000000-0000-0000-0000-000000000049', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'fascinating', 'extremely interesting', 'hấp dẫn', '/ˈfæsəneɪtɪŋ/', '2024-03-10 08:46:00+00'),
('30000000-0000-0000-0000-000000000050', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'remarkable', 'worthy of attention; striking', 'đáng chú ý', '/rɪˈmɑːrkəbl/', '2024-03-10 08:47:00+00'),
('30000000-0000-0000-0000-000000000051', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'tremendous', 'very great in amount, scale, or intensity', 'to lớn', '/trɪˈmendəs/', '2024-03-10 08:48:00+00'),
('30000000-0000-0000-0000-000000000052', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'literally', 'in a literal manner or sense; exactly', 'thực sự', '/ˈlɪtərəli/', '2024-03-10 08:49:00+00'),
('30000000-0000-0000-0000-000000000053', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'essentially', 'in the most important respects; fundamentally', 'về cơ bản', '/ɪˈsenʃəli/', '2024-03-10 08:50:00+00'),
('30000000-0000-0000-0000-000000000054', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'particularly', 'to a higher degree than is usual or average', 'đặc biệt', '/pərˈtɪkjələrli/', '2024-03-10 08:51:00+00'),
('30000000-0000-0000-0000-000000000055', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'definitely', 'without doubt; certainly', 'chắc chắn', '/ˈdefɪnətli/', '2024-03-10 08:52:00+00'),
('30000000-0000-0000-0000-000000000056', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'absolutely', 'with no qualification, restriction, or limitation; totally', 'hoàn toàn', '/ˈæbsəˌlutli/', '2024-03-10 08:53:00+00'),
('30000000-0000-0000-0000-000000000057', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'generally', 'in most cases; usually', 'nói chung', '/ˈdʒenərəli/', '2024-03-10 08:54:00+00'),
('30000000-0000-0000-0000-000000000058', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'obviously', 'in a way that is easily perceived or understood; clearly', 'rõ ràng', '/ˈɑːbviəsli/', '2024-03-10 08:55:00+00'),
('30000000-0000-0000-0000-000000000059', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'personally', 'as far as oneself is concerned', 'cá nhân tôi', '/ˈpɜːrsənəli/', '2024-03-10 08:56:00+00'),
('30000000-0000-0000-0000-000000000060', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'honestly', 'in a truthful way; really (used for emphasis)', 'thật sự', '/ˈɑːnɪstli/', '2024-03-10 08:57:00+00'),
('30000000-0000-0000-0000-000000000061', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'fortunately', 'it is fortunate that', 'may mắn thay', '/ˈfɔːrtʃənətli/', '2024-03-10 08:58:00+00'),
('30000000-0000-0000-0000-000000000062', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'unfortunately', 'it is unfortunate that; unluckily', 'tiếc là', '/ʌnˈfɔːrtʃənətli/', '2024-03-10 08:59:00+00'),
('30000000-0000-0000-0000-000000000063', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'incredibly', 'to a great degree; extremely', 'cực kỳ', '/ɪnˈkredəbli/', '2024-03-10 09:00:00+00'),
('30000000-0000-0000-0000-000000000064', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'somewhat', 'to a moderate extent or by a moderate amount', 'phần nào', '/ˈsʌmwʌt/', '2024-03-10 09:01:00+00'),
('30000000-0000-0000-0000-000000000065', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'occasionally', 'at infrequent or irregular intervals; now and then', 'thỉnh thoảng', '/əˈkeɪʒənəli/', '2024-03-10 09:02:00+00');

-- Technology Terms (25 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000066', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'algorithm', 'a process or set of rules to be followed in calculations', 'thuật toán', '/ˈælɡərɪðəm/', '2024-04-05 11:15:00+00'),
('30000000-0000-0000-0000-000000000067', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'artificial intelligence', 'the simulation of human intelligence in machines', 'trí tuệ nhân tạo', '/ˌɑːrtɪˈfɪʃl ɪnˈtelɪdʒəns/', '2024-04-05 11:16:00+00'),
('30000000-0000-0000-0000-000000000068', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'blockchain', 'a system of recording information that makes it difficult to change or hack', 'chuỗi khối', '/ˈblɑːktʃeɪn/', '2024-04-05 11:17:00+00'),
('30000000-0000-0000-0000-000000000069', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'cloud computing', 'the delivery of computing services over the internet', 'điện toán đám mây', '/klaʊd kəmˈpjuːtɪŋ/', '2024-04-05 11:18:00+00'),
('30000000-0000-0000-0000-000000000070', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'cybersecurity', 'the practice of protecting systems and data from digital attacks', 'an ninh mạng', '/ˈsaɪbərsɪˌkjʊrəti/', '2024-04-05 11:19:00+00'),
('30000000-0000-0000-0000-000000000071', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'database', 'a structured set of data held in a computer', 'cơ sở dữ liệu', '/ˈdeɪtəbeɪs/', '2024-04-05 11:20:00+00'),
('30000000-0000-0000-0000-000000000072', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'encryption', 'the process of converting information into a secret code', 'mã hóa', '/ɪnˈkrɪpʃn/', '2024-04-05 11:21:00+00'),
('30000000-0000-0000-0000-000000000073', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'firewall', 'a network security system that monitors and controls network traffic', 'tường lửa', '/ˈfaɪərwɔːl/', '2024-04-05 11:22:00+00'),
('30000000-0000-0000-0000-000000000074', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'interface', 'a point where two systems meet and interact', 'giao diện', '/ˈɪntərfeɪs/', '2024-04-05 11:23:00+00'),
('30000000-0000-0000-0000-000000000075', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'machine learning', 'a type of AI that enables computers to learn without being programmed', 'máy học', '/məˈʃiːn ˈlɜːrnɪŋ/', '2024-04-05 11:24:00+00'),
('30000000-0000-0000-0000-000000000076', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'network', 'a group of interconnected computers', 'mạng', '/ˈnetwɜːrk/', '2024-04-05 11:25:00+00'),
('30000000-0000-0000-0000-000000000077', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'operating system', 'system software that manages computer hardware and software resources', 'hệ điều hành', '/ˈɑːpəreɪtɪŋ ˈsɪstəm/', '2024-04-05 11:26:00+00'),
('30000000-0000-0000-0000-000000000078', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'programming', 'the process of creating a set of instructions for a computer', 'lập trình', '/ˈproʊɡræmɪŋ/', '2024-04-05 11:27:00+00'),
('30000000-0000-0000-0000-000000000079', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'server', 'a computer or system that provides resources to other computers', 'máy chủ', '/ˈsɜːrvər/', '2024-04-05 11:28:00+00'),
('30000000-0000-0000-0000-000000000080', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'software', 'computer programs and other operating information', 'phần mềm', '/ˈsɔːftwer/', '2024-04-05 11:29:00+00'),
('30000000-0000-0000-0000-000000000081', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'virtual reality', 'computer-generated simulation of a three-dimensional environment', 'thực tế ảo', '/ˈvɜːrtʃuəl riˈæləti/', '2024-04-05 11:30:00+00'),
('30000000-0000-0000-0000-000000000082', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'bandwidth', 'the maximum rate of data transfer across a network path', 'băng thông', '/ˈbændwɪdθ/', '2024-04-05 11:31:00+00'),
('30000000-0000-0000-0000-000000000083', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'backup', 'a copy of computer data stored separately for protection', 'sao lưu', '/ˈbækʌp/', '2024-04-05 11:32:00+00'),
('30000000-0000-0000-0000-000000000084', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'debug', 'identify and remove errors from computer programs', 'gỡ lỗi', '/diˈbʌɡ/', '2024-04-05 11:33:00+00'),
('30000000-0000-0000-0000-000000000085', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'download', 'copy data from one computer system to another', 'tải xuống', '/ˈdaʊnloʊd/', '2024-04-05 11:34:00+00'),
('30000000-0000-0000-0000-000000000086', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'upload', 'transfer data from one computer to another', 'tải lên', '/ˈʌploʊd/', '2024-04-05 11:35:00+00'),
('30000000-0000-0000-0000-000000000087', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'virus', 'a malicious program designed to replicate and spread', 'vi-rút', '/ˈvaɪrəs/', '2024-04-05 11:36:00+00'),
('30000000-0000-0000-0000-000000000088', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'website', 'a collection of web pages and related content', 'trang web', '/ˈwebsaɪt/', '2024-04-05 11:37:00+00'),
('30000000-0000-0000-0000-000000000089', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'wireless', 'using radio, microwaves, etc. rather than wires or cables', 'không dây', '/ˈwaɪrləs/', '2024-04-05 11:38:00+00'),
('30000000-0000-0000-0000-000000000090', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'cryptocurrency', 'a digital currency secured by cryptography', 'tiền mã hóa', '/ˈkrɪptoʊˌkɜːrənsi/', '2024-04-05 11:39:00+00');

-- My Daily English (10 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000091', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'grocery', 'food and other items sold in a supermarket', 'tạp hóa', '/ˈɡroʊsəri/', '2024-05-01 15:15:00+00'),
('30000000-0000-0000-0000-000000000092', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'laundry', 'clothes and linens that need to be washed', 'giặt giũ', '/ˈlɔːndri/', '2024-05-01 15:16:00+00'),
('30000000-0000-0000-0000-000000000093', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'appointment', 'an arrangement to meet someone at a particular time', 'cuộc hẹn', '/əˈpɔɪntmənt/', '2024-05-01 15:17:00+00'),
('30000000-0000-0000-0000-000000000094', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'commute', 'travel some distance between home and work on a regular basis', 'đi làm', '/kəˈmjuːt/', '2024-05-01 15:18:00+00'),
('30000000-0000-0000-0000-000000000095', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'neighbor', 'a person living next door to or very near to another', 'hàng xóm', '/ˈneɪbər/', '2024-05-01 15:19:00+00'),
('30000000-0000-0000-0000-000000000096', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'weather', 'the state of the atmosphere at a place and time', 'thời tiết', '/ˈweðər/', '2024-05-01 15:20:00+00'),
('30000000-0000-0000-0000-000000000097', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'traffic', 'vehicles moving on a road or public highway', 'giao thông', '/ˈtræfɪk/', '2024-05-01 15:21:00+00'),
('30000000-0000-0000-0000-000000000098', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'schedule', 'a plan for carrying out a process or procedure', 'lịch trình', '/ˈskedʒuːl/', '2024-05-01 15:22:00+00'),
('30000000-0000-0000-0000-000000000099', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'routine', 'a sequence of actions regularly followed', 'thói quen', '/ruːˈtiːn/', '2024-05-01 15:23:00+00'),
('30000000-0000-0000-0000-000000000100', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', 'exercise', 'activity requiring physical effort to sustain or improve health', 'tập thể dục', '/ˈeksərsaɪz/', '2024-05-01 15:24:00+00');

-- Travel Essentials (8 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000101', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'passport', 'an official document for international travel', 'hộ chiếu', '/ˈpæspɔːrt/', '2024-05-15 16:15:00+00'),
('30000000-0000-0000-0000-000000000102', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'luggage', 'suitcases or other bags for a traveler', 'hành lý', '/ˈlʌɡɪdʒ/', '2024-05-15 16:16:00+00'),
('30000000-0000-0000-0000-000000000103', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'reservation', 'an arrangement to have something kept for particular use', 'đặt chỗ', '/ˌrezərˈveɪʃn/', '2024-05-15 16:17:00+00'),
('30000000-0000-0000-0000-000000000104', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'accommodation', 'a place where someone can live or stay', 'chỗ ở', '/əˌkɑːməˈdeɪʃn/', '2024-05-15 16:18:00+00'),
('30000000-0000-0000-0000-000000000105', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'currency', 'a system of money in general use in a country', 'tiền tệ', '/ˈkɜːrənsi/', '2024-05-15 16:19:00+00'),
('30000000-0000-0000-0000-000000000106', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'departure', 'the action of leaving', 'khởi hành', '/dɪˈpɑːrtʃər/', '2024-05-15 16:20:00+00'),
('30000000-0000-0000-0000-000000000107', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'arrival', 'the action of arriving', 'đến nơi', '/əˈraɪvl/', '2024-05-15 16:21:00+00'),
('30000000-0000-0000-0000-000000000108', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000012', 'customs', 'the official department that administers duties on imported goods', 'hải quan', '/ˈkʌstəmz/', '2024-05-15 16:22:00+00');

-- Food & Cooking (14 words)
INSERT INTO vocabulary (id, list_id, created_by, term, definition, translation, phonetics, created_at) VALUES
('30000000-0000-0000-0000-000000000109', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'ingredient', 'any of the foods or substances that are combined to make a dish', 'nguyên liệu', '/ɪnˈɡriːdiənt/', '2024-06-01 12:15:00+00'),
('30000000-0000-0000-0000-000000000110', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'recipe', 'a set of instructions for preparing a dish', 'công thức nấu ăn', '/ˈresəpi/', '2024-06-01 12:16:00+00'),
('30000000-0000-0000-0000-000000000111', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'seasoning', 'salt, herbs, or spices added to food to enhance flavor', 'gia vị', '/ˈsiːzənɪŋ/', '2024-06-01 12:17:00+00'),
('30000000-0000-0000-0000-000000000112', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'appetizer', 'a small dish of food served before the main course', 'món khai vị', '/ˈæpɪtaɪzər/', '2024-06-01 12:18:00+00'),
('30000000-0000-0000-0000-000000000113', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'cuisine', 'a style or method of cooking', 'ẩm thực', '/kwɪˈziːn/', '2024-06-01 12:19:00+00'),
('30000000-0000-0000-0000-000000000114', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'marinade', 'a sauce in which meat or fish is soaked before cooking', 'nước ướp', '/ˌmærɪˈneɪd/', '2024-06-01 12:20:00+00'),
('30000000-0000-0000-0000-000000000115', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'garnish', 'a decoration or embellishment for food', 'trang trí món ăn', '/ˈɡɑːrnɪʃ/', '2024-06-01 12:21:00+00'),
('30000000-0000-0000-0000-000000000116', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'texture', 'the feel, appearance, or consistency of a surface', 'kết cấu', '/ˈtekstʃər/', '2024-06-01 12:22:00+00'),
('30000000-0000-0000-0000-000000000117', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'portion', 'a part or share of a whole; a serving of food', 'khẩu phần', '/ˈpɔːrʃn/', '2024-06-01 12:23:00+00'),
('30000000-0000-0000-0000-000000000118', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'utensil', 'a tool or implement for practical use', 'dụng cụ', '/juːˈtensl/', '2024-06-01 12:24:00+00'),
('30000000-0000-0000-0000-000000000119', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'beverage', 'a drink, especially one other than water', 'đồ uống', '/ˈbevərɪdʒ/', '2024-06-01 12:25:00+00'),
('30000000-0000-0000-0000-000000000120', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'nutrition', 'the process of providing or obtaining food for health and growth', 'dinh dưỡng', '/nuˈtrɪʃn/', '2024-06-01 12:26:00+00'),
('30000000-0000-0000-0000-000000000121', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'organic', 'produced or involving production without artificial chemicals', 'hữu cơ', '/ɔːrˈɡænɪk/', '2024-06-01 12:27:00+00'),
('30000000-0000-0000-0000-000000000122', '20000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000013', 'vegetarian', 'a person who does not eat meat', 'người ăn chay', '/ˌvedʒəˈteriən/', '2024-06-01 12:28:00+00');

-- =================================================================
-- VOCABULARY EXAMPLES
-- =================================================================
INSERT INTO vocabulary_examples (vocabulary_id, example_sentence, ai_generated) VALUES
-- TOEFL Examples
('30000000-0000-0000-0000-000000000001', 'The region has abundant natural resources that support its economy.', false),
('30000000-0000-0000-0000-000000000002', 'Scientists need to analyze the data carefully before drawing conclusions.', false),
('30000000-0000-0000-0000-000000000003', 'Her argument was coherent and easy to follow.', false),
('30000000-0000-0000-0000-000000000004', 'The report provides a comprehensive overview of the situation.', false),
('30000000-0000-0000-0000-000000000005', 'The experiment will demonstrate the effectiveness of the new method.', false),

-- Business Examples
('30000000-0000-0000-0000-000000000021', 'Let me check the meeting agenda for today.', false),
('30000000-0000-0000-0000-000000000022', 'We need to collaborate with other departments on this project.', false),
('30000000-0000-0000-0000-000000000023', 'The deadline for this report is next Friday.', false),
('30000000-0000-0000-0000-000000000024', 'We must improve our efficiency to reduce costs.', false),
('30000000-0000-0000-0000-000000000025', 'Thank you for your feedback on the proposal.', false),

-- Technology Examples
('30000000-0000-0000-0000-000000000066', 'The search engine uses a complex algorithm to rank results.', false),
('30000000-0000-0000-0000-000000000067', 'Artificial intelligence is transforming many industries.', false),
('30000000-0000-0000-0000-000000000068', 'Blockchain technology ensures secure transactions.', false),
('30000000-0000-0000-0000-000000000069', 'Cloud computing allows access to files from anywhere.', false),
('30000000-0000-0000-0000-000000000070', 'Good cybersecurity practices protect against data breaches.', false),

-- Daily English Examples
('30000000-0000-0000-0000-000000000091', 'I need to buy some grocery items for dinner tonight.', false),
('30000000-0000-0000-0000-000000000092', 'The laundry is piling up in the hamper.', false),
('30000000-0000-0000-0000-000000000093', 'I have a doctor appointment at 3 PM tomorrow.', false),
('30000000-0000-0000-0000-000000000094', 'My daily commute takes about 45 minutes.', false),
('30000000-0000-0000-0000-000000000095', 'Our neighbor is very friendly and helpful.', false);

-- =================================================================
-- WORD SYNONYMS
-- =================================================================
INSERT INTO word_synonyms (word_id, synonym) VALUES
-- TOEFL synonyms
('30000000-0000-0000-0000-000000000001', 'plentiful'),
('30000000-0000-0000-0000-000000000001', 'ample'),
('30000000-0000-0000-0000-000000000002', 'examine'),
('30000000-0000-0000-0000-000000000002', 'study'),
('30000000-0000-0000-0000-000000000003', 'logical'),
('30000000-0000-0000-0000-000000000003', 'consistent'),
('30000000-0000-0000-0000-000000000004', 'complete'),
('30000000-0000-0000-0000-000000000004', 'thorough'),
('30000000-0000-0000-0000-000000000005', 'show'),
('30000000-0000-0000-0000-000000000005', 'prove'),

-- Business synonyms
('30000000-0000-0000-0000-000000000021', 'schedule'),
('30000000-0000-0000-0000-000000000021', 'program'),
('30000000-0000-0000-0000-000000000022', 'cooperate'),
('30000000-0000-0000-0000-000000000022', 'work together'),
('30000000-0000-0000-0000-000000000023', 'due date'),
('30000000-0000-0000-0000-000000000023', 'time limit'),

-- Technology synonyms
('30000000-0000-0000-0000-000000000066', 'procedure'),
('30000000-0000-0000-0000-000000000066', 'method'),
('30000000-0000-0000-0000-000000000071', 'data storage'),
('30000000-0000-0000-0000-000000000071', 'data repository'),
('30000000-0000-0000-0000-000000000074', 'connection'),
('30000000-0000-0000-0000-000000000074', 'link');

-- =================================================================
-- CLASSROOMS
-- =================================================================
INSERT INTO classrooms (id, teacher_id, name, description, join_code, learner_count, classroom_status, is_auto_approval_enabled, capacity_limit, created_at) VALUES
('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'English for Academic Success', 'Advanced English course focusing on academic writing and TOEFL preparation', 'ABC123', 3, 'public', true, 25, '2024-06-01 08:00:00+00'),
('40000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'Business Communication', 'Professional English for workplace communication', 'BUS456', 2, 'public', false, 20, '2024-06-15 09:00:00+00'),
('40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'IELTS Speaking Practice', 'Interactive IELTS speaking preparation with peer practice', 'IEL789', 4, 'public', true, 15, '2024-07-01 10:00:00+00'),
('40000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'Tech English Fundamentals', 'Essential English vocabulary for IT professionals', 'TEC101', 1, 'private', false, 12, '2024-07-10 11:00:00+00');

-- =================================================================
-- CLASSROOM MEMBERS
-- =================================================================
INSERT INTO classroom_members (classroom_id, learner_id, email, join_status, joined_at) VALUES
-- English for Academic Success
('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000011', 'student1@email.com', 'joined', '2024-06-02 10:00:00+00'),
('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000012', 'student2@email.com', 'joined', '2024-06-03 11:00:00+00'),
('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000013', 'student3@email.com', 'joined', '2024-06-04 12:00:00+00'),

-- Business Communication
('40000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000014', 'student4@email.com', 'joined', '2024-06-16 13:00:00+00'),
('40000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000015', 'student5@email.com', 'joined', '2024-06-17 14:00:00+00'),

-- IELTS Speaking Practice
('40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000011', 'student1@email.com', 'joined', '2024-07-02 15:00:00+00'),
('40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000012', 'student2@email.com', 'joined', '2024-07-03 16:00:00+00'),
('40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000013', 'student3@email.com', 'joined', '2024-07-04 17:00:00+00'),
('40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000014', 'student4@email.com', 'joined', '2024-07-05 18:00:00+00'),

-- Tech English Fundamentals
('40000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000015', 'student5@email.com', 'joined', '2024-07-11 19:00:00+00'),

-- Pending requests
('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000016', 'googleuser@gmail.com', 'pending_request', NULL);

-- =================================================================
-- ASSIGNMENTS
-- =================================================================
INSERT INTO assignments (id, classroom_id, vocab_list_id, teacher_id, title, exercise_method, words_per_review, sublist_count, start_date, due_date, created_at) VALUES
('50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'TOEFL Vocabulary Practice Week 1', 'flashcard', 10, 2, '2024-07-15 00:00:00+00', '2024-07-22 23:59:59+00', '2024-07-14 08:00:00+00'),
('50000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'Business Terms Review', 'fill_blank', 8, 2, '2024-07-20 00:00:00+00', '2024-07-27 23:59:59+00', '2024-07-19 09:00:00+00'),
('50000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'IELTS Speaking Vocabulary', 'word_association', 9, 2, '2024-07-25 00:00:00+00', '2024-08-01 23:59:59+00', '2024-07-24 10:00:00+00'),
-- Past assignment (overdue)
('50000000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'Academic Writing Vocabulary', 'flashcard', 6, 2, '2024-07-01 00:00:00+00', '2024-07-08 23:59:59+00', '2024-06-30 08:00:00+00'),
-- Future assignment
('50000000-0000-0000-0000-000000000005', '40000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'Technology Terms Quiz', 'fill_blank', 10, 3, '2024-08-05 00:00:00+00', '2024-08-12 23:59:59+00', '2024-08-01 11:00:00+00');

-- =================================================================
-- LEARNER ASSIGNMENTS
-- =================================================================
INSERT INTO learner_assignments (assignment_id, learner_id, completed_sublist_index, status, score, attempts, completed_at) VALUES
-- TOEFL Vocabulary Practice Week 1
('50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000011', 1, 'in_progress', NULL, 1, NULL),
('50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000012', 2, 'completed', 85, 1, '2024-07-21 14:30:00+00'),
('50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000013', 0, 'not_started', NULL, 0, NULL),

-- Business Terms Review
('50000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000014', 1, 'in_progress', NULL, 1, NULL),
('50000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000015', 0, 'not_started', NULL, 0, NULL),

-- IELTS Speaking Vocabulary
('50000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000011', 0, 'not_started', NULL, 0, NULL),
('50000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000012', 1, 'in_progress', NULL, 1, NULL),
('50000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000013', 2, 'completed', 92, 1, '2024-07-30 16:45:00+00'),
('50000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000014', 0, 'not_started', NULL, 0, NULL),

-- Academic Writing Vocabulary (overdue)
('50000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000011', 0, 'late', NULL, 0, NULL),
('50000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000012', 1, 'late', NULL, 1, NULL),
('50000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000013', 2, 'completed', 78, 2, '2024-07-10 20:15:00+00');

-- =================================================================
-- USER WORD PROGRESS (for spaced repetition)
-- =================================================================
INSERT INTO user_word_progress (user_id, word_id, next_review_date, interval_days, ease_factor, repetitions, correct_count, incorrect_count, last_reviewed_at) VALUES
-- User 1 progress
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000001', '2024-07-31 10:00:00+00', 1, 2.5, 0, 0, 1, '2024-07-30 10:00:00+00'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000002', '2024-08-02 10:00:00+00', 3, 2.6, 2, 2, 0, '2024-07-30 10:00:00+00'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000003', '2024-07-31 10:00:00+00', 1, 2.5, 0, 0, 1, '2024-07-30 10:00:00+00'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000004', '2024-08-05 10:00:00+00', 6, 2.7, 3, 3, 0, '2024-07-30 10:00:00+00'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000005', '2024-07-31 10:00:00+00', 1, 2.5, 0, 1, 1, '2024-07-30 10:00:00+00'),

-- User 2 progress
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000021', '2024-07-31 11:00:00+00', 1, 2.5, 0, 0, 1, '2024-07-30 11:00:00+00'),
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000022', '2024-08-01 11:00:00+00', 2, 2.6, 1, 1, 0, '2024-07-30 11:00:00+00'),
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000023', '2024-07-31 11:00:00+00', 1, 2.5, 0, 1, 1, '2024-07-30 11:00:00+00'),
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000024', '2024-08-03 11:00:00+00', 4, 2.7, 2, 2, 0, '2024-07-30 11:00:00+00'),

-- User 3 progress
('00000000-0000-0000-0000-000000000013', '30000000-0000-0000-0000-000000000048', '2024-07-31 12:00:00+00', 1, 2.5, 0, 0, 1, '2024-07-30 12:00:00+00'),
('00000000-0000-0000-0000-000000000013', '30000000-0000-0000-0000-000000000049', '2024-08-01 12:00:00+00', 2, 2.6, 1, 1, 0, '2024-07-30 12:00:00+00'),
('00000000-0000-0000-0000-000000000013', '30000000-0000-0000-0000-000000000050', '2024-07-31 12:00:00+00', 1, 2.5, 0, 1, 1, '2024-07-30 12:00:00+00');

-- =================================================================
-- REVISION SESSIONS
-- =================================================================
INSERT INTO revision_sessions (id, user_id, vocab_list_id, session_type, status, started_at, completed_at, score, total_words, correct_answers, word_ids) VALUES
-- Completed sessions
('60000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000001', 'flashcard', 'completed', '2024-07-29 10:00:00+00', '2024-07-29 10:15:00+00', 80, 5, 4, '["30000000-0000-0000-0000-000000000001", "30000000-0000-0000-0000-000000000002", "30000000-0000-0000-0000-000000000003", "30000000-0000-0000-0000-000000000004", "30000000-0000-0000-0000-000000000005"]'),
('60000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000002', 'fill_blank', 'completed', '2024-07-29 14:00:00+00', '2024-07-29 14:20:00+00', 90, 4, 4, '["30000000-0000-0000-0000-000000000021", "30000000-0000-0000-0000-000000000022", "30000000-0000-0000-0000-000000000023", "30000000-0000-0000-0000-000000000024"]'),
('60000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000004', 'word_association', 'completed', '2024-07-30 16:00:00+00', '2024-07-30 16:25:00+00', 75, 6, 5, '["30000000-0000-0000-0000-000000000048", "30000000-0000-0000-0000-000000000049", "30000000-0000-0000-0000-000000000050", "30000000-0000-0000-0000-000000000051", "30000000-0000-0000-0000-000000000052", "30000000-0000-0000-0000-000000000053"]'),

-- Active session
('60000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000002', 'flashcard', 'in_progress', '2024-07-31 09:00:00+00', NULL, NULL, 5, 2, '["30000000-0000-0000-0000-000000000025", "30000000-0000-0000-0000-000000000026", "30000000-0000-0000-0000-000000000027", "30000000-0000-0000-0000-000000000028", "30000000-0000-0000-0000-000000000029"]');

-- =================================================================
-- SESSION WORD RESULTS
-- =================================================================
INSERT INTO session_word_results (session_id, word_id, result, response_time_ms, created_at) VALUES
-- Session 1 results
('60000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'incorrect', 3500, '2024-07-29 10:02:00+00'),
('60000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', 'correct', 2800, '2024-07-29 10:05:00+00'),
('60000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', 'correct', 4200, '2024-07-29 10:08:00+00'),
('60000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000004', 'correct', 3000, '2024-07-29 10:11:00+00'),
('60000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000005', 'correct', 2500, '2024-07-29 10:14:00+00'),

-- Session 2 results
('60000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000021', 'correct', 2200, '2024-07-29 14:03:00+00'),
('60000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000022', 'correct', 3100, '2024-07-29 14:08:00+00'),
('60000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000023', 'correct', 1800, '2024-07-29 14:12:00+00'),
('60000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000024', 'correct', 2600, '2024-07-29 14:18:00+00'),

-- Session 3 results
('60000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000048', 'incorrect', 4500, '2024-07-30 16:03:00+00'),
('60000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000049', 'correct', 2900, '2024-07-30 16:08:00+00'),
('60000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000050', 'correct', 3200, '2024-07-30 16:13:00+00'),
('60000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000051', 'correct', 2100, '2024-07-30 16:18:00+00'),
('60000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000052', 'correct', 3800, '2024-07-30 16:21:00+00'),
('60000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000053', 'correct', 2700, '2024-07-30 16:24:00+00'),

-- Active session partial results
('60000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000025', 'correct', 2400, '2024-07-31 09:03:00+00'),
('60000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000026', 'correct', 3600, '2024-07-31 09:08:00+00');

-- =================================================================
-- CLASSROOM INVITATIONS
-- =================================================================
INSERT INTO classroom_invitations (id, classroom_id, email, token, expires_at, used_at, status) VALUES
('70000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'newstudent1@email.com', 'inv_token_abc123', '2024-08-07 23:59:59+00', NULL, 'pending_invite'),
('70000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', 'newstudent2@email.com', 'inv_token_def456', '2024-08-05 23:59:59+00', NULL, 'pending_invite'),
('70000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000003', 'student6@email.com', 'inv_token_ghi789', '2024-07-25 23:59:59+00', '2024-07-20 10:00:00+00', 'joined');

-- =================================================================
-- NOTIFICATIONS
-- =================================================================
INSERT INTO notifications (id, recipient_id, notification_type, title, message, is_read, metadata, action_url, created_at) VALUES
('80000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000011', 'assignment', 'New Assignment Available', 'You have a new assignment "TOEFL Vocabulary Practice Week 1" in English for Academic Success', false, '{"assignment_id": "50000000-0000-0000-0000-000000000001", "classroom_id": "40000000-0000-0000-0000-000000000001"}', '/assignments/50000000-0000-0000-0000-000000000001', '2024-07-14 08:30:00+00'),
('80000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000012', 'reminder', 'Assignment Due Soon', 'Your assignment "Business Terms Review" is due in 2 days', false, '{"assignment_id": "50000000-0000-0000-0000-000000000002", "days_remaining": 2}', '/assignments/50000000-0000-0000-0000-000000000002', '2024-07-25 10:00:00+00'),
('80000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000013', 'achievement', 'Great Job!', 'You completed the IELTS Speaking Vocabulary assignment with a score of 92%!', true, '{"score": 92, "assignment_id": "50000000-0000-0000-0000-000000000003"}', '/achievements', '2024-07-30 16:46:00+00'),
('80000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', 'system', 'New Student Joined', 'A new student has joined your classroom "English for Academic Success"', false, '{"classroom_id": "40000000-0000-0000-0000-000000000001", "student_name": "Alex Nguyen"}', '/classrooms/40000000-0000-0000-0000-000000000001/learners', '2024-06-02 10:30:00+00'),
('80000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000011', 'reminder', 'Daily Study Reminder', 'Don''t forget to review your vocabulary today! You''re on a 3-day streak.', false, '{"streak": 3, "daily_goal": 10}', '/review', '2024-07-31 08:00:00+00');

-- =================================================================
-- ACHIEVEMENTS
-- =================================================================
INSERT INTO achievements (id, user_id, achievement_type, title, description, icon_url, earned_at, metadata) VALUES
('90000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000012', 'streak', 'Week Warrior', 'Maintained a 7-day learning streak', '/icons/streak-7.png', '2024-07-29 20:00:00+00', '{"streak_days": 7}'),
('90000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000013', 'words_learned', 'Vocabulary Master', 'Learned 100 new words', '/icons/vocab-100.png', '2024-07-25 15:30:00+00', '{"words_count": 100}'),
('90000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000011', 'perfect_session', 'Perfect Score', 'Achieved 100% accuracy in a learning session', '/icons/perfect.png', '2024-07-20 14:45:00+00', '{"session_id": "60000000-0000-0000-0000-000000000001", "accuracy": 100}'),
('90000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000014', 'assignment', 'Assignment Ace', 'Completed first assignment with excellent performance', '/icons/assignment.png', '2024-07-21 16:20:00+00', '{"assignment_id": "50000000-0000-0000-0000-000000000001", "score": 85}');

-- =================================================================
-- REPORTS
-- =================================================================
INSERT INTO reports (id, reporter_id, word_id, reason, status, created_at) VALUES
('A0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000015', '30000000-0000-0000-0000-000000000067', 'The definition seems unclear and could be more precise', 'open', '2024-07-30 11:30:00+00'),
('A0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000013', '30000000-0000-0000-0000-000000000025', 'The pronunciation guide appears to be incorrect', 'resolved', '2024-07-28 14:15:00+00'),
('A0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000105', 'Translation to Vietnamese is not accurate', 'open', '2024-07-29 09:45:00+00');

-- =================================================================
-- AUDIT LOGS
-- =================================================================
INSERT INTO audit_logs (id, user_id, action, target_type, target_id, details, ip_address, user_agent, created_at) VALUES
('B0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'CREATE', 'vocabulary_list', '20000000-0000-0000-0000-000000000001', '{"title": "TOEFL Essential Vocabulary", "word_count": 20}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2024-03-01 08:00:00+00'),
('B0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'CREATE', 'classroom', '40000000-0000-0000-0000-000000000001', '{"name": "English for Academic Success", "capacity": 25}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2024-06-01 08:00:00+00'),
('B0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000011', 'JOIN', 'classroom', '40000000-0000-0000-0000-000000000001', '{"join_method": "join_code", "join_code": "ABC123"}', '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0)', '2024-06-02 10:00:00+00'),
('B0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000013', 'COMPLETE', 'assignment', '50000000-0000-0000-0000-000000000003', '{"score": 92, "attempts": 1}', '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)', '2024-07-30 16:45:00+00'),
('B0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000012', 'UPDATE', 'user_profile', '00000000-0000-0000-0000-000000000012', '{"field": "daily_goal", "old_value": 10, "new_value": 12}', '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2024-07-29 13:20:00+00');

-- Re-enable triggers
SET session_replication_role = DEFAULT;

-- =================================================================
-- DEMO-READY FRESHNESS PASS
-- =================================================================
-- Keep the seeded demo attractive for screenshots even when the project is
-- reset months after the original course data was authored.

UPDATE users
SET
    created_at = CASE id
        WHEN '00000000-0000-0000-0000-000000000001' THEN NOW() - INTERVAL '180 days'
        WHEN '00000000-0000-0000-0000-000000000002' THEN NOW() - INTERVAL '150 days'
        WHEN '00000000-0000-0000-0000-000000000003' THEN NOW() - INTERVAL '120 days'
        WHEN '00000000-0000-0000-0000-000000000004' THEN NOW() - INTERVAL '2 days'
        WHEN '00000000-0000-0000-0000-000000000011' THEN NOW() - INTERVAL '75 days'
        WHEN '00000000-0000-0000-0000-000000000012' THEN NOW() - INTERVAL '62 days'
        WHEN '00000000-0000-0000-0000-000000000013' THEN NOW() - INTERVAL '48 days'
        WHEN '00000000-0000-0000-0000-000000000014' THEN NOW() - INTERVAL '30 days'
        WHEN '00000000-0000-0000-0000-000000000015' THEN NOW() - INTERVAL '18 days'
        WHEN '00000000-0000-0000-0000-000000000016' THEN NOW() - INTERVAL '7 days'
        ELSE created_at
    END,
    updated_at = NOW();

UPDATE users
SET account_status = 'suspended', updated_at = NOW() - INTERVAL '2 days'
WHERE id = '00000000-0000-0000-0000-000000000015';

INSERT INTO user_deactivation (user_id, deactivated_by, deactivated_at, deactivation_reason) VALUES
('00000000-0000-0000-0000-000000000015', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '2 days', 'Repeated inappropriate vocabulary reports during demo moderation review')
ON CONFLICT (user_id, deactivated_by) DO UPDATE SET
    deactivated_at = EXCLUDED.deactivated_at,
    deactivation_reason = EXCLUDED.deactivation_reason;

UPDATE teacher_requests
SET
    created_at = CASE id
        WHEN '10000000-0000-0000-0000-000000000001' THEN NOW() - INTERVAL '120 days'
        WHEN '10000000-0000-0000-0000-000000000002' THEN NOW() - INTERVAL '90 days'
        WHEN '10000000-0000-0000-0000-000000000003' THEN NOW() - INTERVAL '1 day'
        ELSE created_at
    END,
    school_email = CASE id
        WHEN '10000000-0000-0000-0000-000000000001' THEN 'sarah.johnson@ishcmc.edu.vn'
        WHEN '10000000-0000-0000-0000-000000000002' THEN 'david.chen@vnu.edu.vn'
        WHEN '10000000-0000-0000-0000-000000000003' THEN 'emily.garcia@abclanguage.edu.vn'
        ELSE school_email
    END,
    additional_notes = CASE id
        WHEN '10000000-0000-0000-0000-000000000003' THEN 'CELTA-certified teacher requesting classroom tools for a weekend IELTS speaking cohort.'
        ELSE additional_notes
    END;

UPDATE vocab_lists
SET
    title = CASE id
        WHEN '20000000-0000-0000-0000-000000000001' THEN 'TOEFL Academic Core'
        WHEN '20000000-0000-0000-0000-000000000002' THEN 'Business English Meetings'
        WHEN '20000000-0000-0000-0000-000000000004' THEN 'IELTS Speaking Boost'
        WHEN '20000000-0000-0000-0000-000000000005' THEN 'Tech English Essentials'
        WHEN '20000000-0000-0000-0000-000000000006' THEN 'Everyday English Essentials'
        WHEN '20000000-0000-0000-0000-000000000007' THEN 'Travel Survival Kit'
        ELSE title
    END,
    description = CASE id
        WHEN '20000000-0000-0000-0000-000000000001' THEN 'High-frequency academic words for TOEFL reading, listening, and integrated writing tasks.'
        WHEN '20000000-0000-0000-0000-000000000002' THEN 'Meeting, planning, negotiation, and workplace vocabulary for professional communication.'
        WHEN '20000000-0000-0000-0000-000000000004' THEN 'Natural phrases and topic vocabulary for confident IELTS speaking answers.'
        WHEN '20000000-0000-0000-0000-000000000005' THEN 'Modern software, web, security, and product vocabulary for technology learners.'
        WHEN '20000000-0000-0000-0000-000000000006' THEN 'Daily words for errands, schedules, commuting, weather, and small talk.'
        WHEN '20000000-0000-0000-0000-000000000007' THEN 'Airport, hotel, transport, and travel problem-solving vocabulary.'
        ELSE description
    END,
    created_at = CASE id
        WHEN '20000000-0000-0000-0000-000000000006' THEN NOW() - INTERVAL '21 days'
        WHEN '20000000-0000-0000-0000-000000000007' THEN NOW() - INTERVAL '18 days'
        WHEN '20000000-0000-0000-0000-000000000008' THEN NOW() - INTERVAL '15 days'
        ELSE NOW() - INTERVAL '60 days'
    END,
    updated_at = CASE id
        WHEN '20000000-0000-0000-0000-000000000006' THEN NOW() - INTERVAL '25 minutes'
        WHEN '20000000-0000-0000-0000-000000000001' THEN NOW() - INTERVAL '2 hours'
        WHEN '20000000-0000-0000-0000-000000000002' THEN NOW() - INTERVAL '4 hours'
        WHEN '20000000-0000-0000-0000-000000000004' THEN NOW() - INTERVAL '1 day'
        WHEN '20000000-0000-0000-0000-000000000005' THEN NOW() - INTERVAL '2 days'
        ELSE NOW() - INTERVAL '3 days'
    END,
    view_count = CASE id
        WHEN '20000000-0000-0000-0000-000000000001' THEN 184
        WHEN '20000000-0000-0000-0000-000000000004' THEN 156
        WHEN '20000000-0000-0000-0000-000000000005' THEN 131
        WHEN '20000000-0000-0000-0000-000000000002' THEN 118
        WHEN '20000000-0000-0000-0000-000000000007' THEN 92
        WHEN '20000000-0000-0000-0000-000000000008' THEN 74
        ELSE view_count
    END;

INSERT INTO user_list_history (user_id, list_id, last_accessed_at) VALUES
-- Alex Nguyen learner homepage
('00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000006', NOW() - INTERVAL '12 minutes'),
('00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000001', NOW() - INTERVAL '1 hour'),
('00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000004', NOW() - INTERVAL '6 hours'),
('00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000002', NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000005', NOW() - INTERVAL '2 days'),
-- Maria Rodriguez learner homepage
('00000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000007', NOW() - INTERVAL '18 minutes'),
('00000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000002', NOW() - INTERVAL '3 hours'),
('00000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000001', NOW() - INTERVAL '1 day'),
-- Teacher homepages
('00000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', NOW() - INTERVAL '20 minutes'),
('00000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', NOW() - INTERVAL '2 hours'),
('00000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003', NOW() - INTERVAL '8 hours'),
('00000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000004', NOW() - INTERVAL '45 minutes'),
('00000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000005', NOW() - INTERVAL '5 hours')
ON CONFLICT (user_id, list_id) DO UPDATE SET
    last_accessed_at = EXCLUDED.last_accessed_at;

INSERT INTO user_word_progress (
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
-- Alex Nguyen: Today review cards plus a usable self-owned review list.
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000091', NOW() - INTERVAL '3 hours', 1, 2.35, 2, 4, 1, NOW() - INTERVAL '1 day', 'flashcard'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000092', NOW() - INTERVAL '2 hours', 1, 2.40, 3, 5, 1, NOW() - INTERVAL '1 day', 'fill_blank'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000093', NOW() - INTERVAL '90 minutes', 2, 2.45, 3, 6, 0, NOW() - INTERVAL '2 days', 'flashcard'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000094', NOW() - INTERVAL '40 minutes', 3, 2.50, 4, 8, 1, NOW() - INTERVAL '3 days', 'fill_blank'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000095', NOW() - INTERVAL '10 minutes', 1, 2.20, 1, 2, 2, NOW() - INTERVAL '1 day', 'flashcard'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000096', CURRENT_DATE + INTERVAL '1 day' + INTERVAL '9 hours', 1, 2.50, 1, 2, 0, NOW() - INTERVAL '12 hours', 'flashcard'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000097', CURRENT_DATE + INTERVAL '3 days' + INTERVAL '10 hours', 3, 2.60, 2, 4, 0, NOW() - INTERVAL '2 days', 'fill_blank'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000098', CURRENT_DATE + INTERVAL '6 days' + INTERVAL '8 hours', 6, 2.80, 3, 7, 0, NOW() - INTERVAL '6 days', 'flashcard'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000001', NOW() - INTERVAL '4 hours', 1, 2.40, 2, 3, 1, NOW() - INTERVAL '1 day', 'flashcard'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000021', NOW() - INTERVAL '2 hours', 2, 2.55, 3, 5, 1, NOW() - INTERVAL '2 days', 'fill_blank'),
('00000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000048', CURRENT_DATE + INTERVAL '2 days' + INTERVAL '13 hours', 2, 2.45, 2, 3, 1, NOW() - INTERVAL '1 day', 'flashcard'),
-- Teacher 1: due cards for teacher demo login.
('00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', NOW() - INTERVAL '2 hours', 1, 2.50, 3, 7, 0, NOW() - INTERVAL '1 day', 'flashcard'),
('00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', NOW() - INTERVAL '90 minutes', 1, 2.45, 2, 5, 1, NOW() - INTERVAL '1 day', 'fill_blank'),
('00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000021', NOW() - INTERVAL '3 hours', 2, 2.55, 4, 9, 1, NOW() - INTERVAL '2 days', 'flashcard'),
('00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000022', NOW() - INTERVAL '1 hour', 2, 2.65, 4, 8, 0, NOW() - INTERVAL '2 days', 'fill_blank'),
('00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000040', CURRENT_DATE + INTERVAL '2 days' + INTERVAL '9 hours', 4, 2.70, 5, 10, 1, NOW() - INTERVAL '4 days', 'flashcard'),
('00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000041', NOW() - INTERVAL '30 minutes', 1, 2.30, 1, 2, 1, NOW() - INTERVAL '12 hours', 'fill_blank'),
-- Maria Rodriguez: travel list for account/statistics screenshots.
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000101', NOW() - INTERVAL '2 hours', 1, 2.30, 1, 2, 1, NOW() - INTERVAL '1 day', 'flashcard'),
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000102', NOW() - INTERVAL '1 hour', 2, 2.50, 2, 4, 0, NOW() - INTERVAL '2 days', 'fill_blank'),
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000103', CURRENT_DATE + INTERVAL '1 day' + INTERVAL '11 hours', 1, 2.40, 1, 3, 0, NOW() - INTERVAL '1 day', 'flashcard'),
('00000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000104', NOW() - INTERVAL '20 minutes', 3, 2.60, 3, 6, 1, NOW() - INTERVAL '3 days', 'fill_blank')
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

INSERT INTO revision_sessions (id, user_id, vocab_list_id, session_type, status, started_at, completed_at, score, total_words, correct_answers, word_ids) VALUES
('60000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000006', 'flashcard', 'completed', NOW() - INTERVAL '1 day' - INTERVAL '35 minutes', NOW() - INTERVAL '1 day' - INTERVAL '18 minutes', 92, 5, 5, '["30000000-0000-0000-0000-000000000091", "30000000-0000-0000-0000-000000000092", "30000000-0000-0000-0000-000000000093", "30000000-0000-0000-0000-000000000094", "30000000-0000-0000-0000-000000000095"]'::jsonb),
('60000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000001', 'fill_blank', 'completed', NOW() - INTERVAL '3 days' - INTERVAL '40 minutes', NOW() - INTERVAL '3 days' - INTERVAL '15 minutes', 86, 5, 4, '["30000000-0000-0000-0000-000000000001", "30000000-0000-0000-0000-000000000002", "30000000-0000-0000-0000-000000000003", "30000000-0000-0000-0000-000000000004", "30000000-0000-0000-0000-000000000005"]'::jsonb),
('60000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000002', 'flashcard', 'completed', NOW() - INTERVAL '7 days' - INTERVAL '25 minutes', NOW() - INTERVAL '7 days' - INTERVAL '8 minutes', 88, 4, 4, '["30000000-0000-0000-0000-000000000021", "30000000-0000-0000-0000-000000000022", "30000000-0000-0000-0000-000000000023", "30000000-0000-0000-0000-000000000024"]'::jsonb),
('60000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000007', 'fill_blank', 'completed', NOW() - INTERVAL '2 days' - INTERVAL '30 minutes', NOW() - INTERVAL '2 days' - INTERVAL '12 minutes', 90, 4, 4, '["30000000-0000-0000-0000-000000000101", "30000000-0000-0000-0000-000000000102", "30000000-0000-0000-0000-000000000103", "30000000-0000-0000-0000-000000000104"]'::jsonb)
ON CONFLICT (id) DO UPDATE SET
    started_at = EXCLUDED.started_at,
    completed_at = EXCLUDED.completed_at,
    score = EXCLUDED.score,
    total_words = EXCLUDED.total_words,
    correct_answers = EXCLUDED.correct_answers,
    status = EXCLUDED.status,
    word_ids = EXCLUDED.word_ids;

UPDATE revision_sessions
SET
    started_at = CASE id
        WHEN '60000000-0000-0000-0000-000000000001' THEN NOW() - INTERVAL '14 days' - INTERVAL '30 minutes'
        WHEN '60000000-0000-0000-0000-000000000002' THEN NOW() - INTERVAL '10 days' - INTERVAL '35 minutes'
        WHEN '60000000-0000-0000-0000-000000000003' THEN NOW() - INTERVAL '5 days' - INTERVAL '40 minutes'
        WHEN '60000000-0000-0000-0000-000000000004' THEN NOW() - INTERVAL '9 minutes'
        ELSE started_at
    END,
    completed_at = CASE id
        WHEN '60000000-0000-0000-0000-000000000001' THEN NOW() - INTERVAL '14 days' - INTERVAL '12 minutes'
        WHEN '60000000-0000-0000-0000-000000000002' THEN NOW() - INTERVAL '10 days' - INTERVAL '16 minutes'
        WHEN '60000000-0000-0000-0000-000000000003' THEN NOW() - INTERVAL '5 days' - INTERVAL '18 minutes'
        ELSE completed_at
    END
WHERE id IN (
    '60000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000002',
    '60000000-0000-0000-0000-000000000003',
    '60000000-0000-0000-0000-000000000004'
);

INSERT INTO monthly_user_stats (user_id, month_start_date, cumulative_words_mastered) VALUES
('00000000-0000-0000-0000-000000000011', date_trunc('month', CURRENT_DATE - INTERVAL '5 months')::date, 18),
('00000000-0000-0000-0000-000000000011', date_trunc('month', CURRENT_DATE - INTERVAL '4 months')::date, 36),
('00000000-0000-0000-0000-000000000011', date_trunc('month', CURRENT_DATE - INTERVAL '3 months')::date, 58),
('00000000-0000-0000-0000-000000000011', date_trunc('month', CURRENT_DATE - INTERVAL '2 months')::date, 83),
('00000000-0000-0000-0000-000000000011', date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date, 107),
('00000000-0000-0000-0000-000000000011', date_trunc('month', CURRENT_DATE)::date, 128),
('00000000-0000-0000-0000-000000000012', date_trunc('month', CURRENT_DATE - INTERVAL '4 months')::date, 22),
('00000000-0000-0000-0000-000000000012', date_trunc('month', CURRENT_DATE - INTERVAL '3 months')::date, 41),
('00000000-0000-0000-0000-000000000012', date_trunc('month', CURRENT_DATE - INTERVAL '2 months')::date, 69),
('00000000-0000-0000-0000-000000000012', date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date, 88),
('00000000-0000-0000-0000-000000000012', date_trunc('month', CURRENT_DATE)::date, 102)
ON CONFLICT (user_id, month_start_date) DO UPDATE SET
    cumulative_words_mastered = EXCLUDED.cumulative_words_mastered,
    updated_at = NOW();

UPDATE assignments
SET
    start_date = CASE id
        WHEN '50000000-0000-0000-0000-000000000001' THEN CURRENT_DATE - INTERVAL '4 days'
        WHEN '50000000-0000-0000-0000-000000000002' THEN CURRENT_DATE - INTERVAL '2 days'
        WHEN '50000000-0000-0000-0000-000000000003' THEN CURRENT_DATE - INTERVAL '1 day'
        WHEN '50000000-0000-0000-0000-000000000004' THEN CURRENT_DATE - INTERVAL '12 days'
        WHEN '50000000-0000-0000-0000-000000000005' THEN CURRENT_DATE + INTERVAL '3 days'
        ELSE start_date
    END,
    due_date = CASE id
        WHEN '50000000-0000-0000-0000-000000000001' THEN CURRENT_DATE + INTERVAL '3 days' + INTERVAL '23 hours'
        WHEN '50000000-0000-0000-0000-000000000002' THEN CURRENT_DATE + INTERVAL '5 days' + INTERVAL '23 hours'
        WHEN '50000000-0000-0000-0000-000000000003' THEN CURRENT_DATE + INTERVAL '7 days' + INTERVAL '23 hours'
        WHEN '50000000-0000-0000-0000-000000000004' THEN CURRENT_DATE - INTERVAL '3 days'
        WHEN '50000000-0000-0000-0000-000000000005' THEN CURRENT_DATE + INTERVAL '10 days' + INTERVAL '23 hours'
        ELSE due_date
    END,
    updated_at = NOW();

UPDATE learner_assignments
SET completed_at = CASE
    WHEN status = 'completed' THEN NOW() - INTERVAL '2 days'
    ELSE completed_at
END;

UPDATE notifications
SET created_at = CASE id
    WHEN '80000000-0000-0000-0000-000000000001' THEN NOW() - INTERVAL '5 hours'
    WHEN '80000000-0000-0000-0000-000000000002' THEN NOW() - INTERVAL '3 hours'
    WHEN '80000000-0000-0000-0000-000000000003' THEN NOW() - INTERVAL '2 days'
    WHEN '80000000-0000-0000-0000-000000000004' THEN NOW() - INTERVAL '6 hours'
    WHEN '80000000-0000-0000-0000-000000000005' THEN NOW() - INTERVAL '30 minutes'
    ELSE created_at
END;

UPDATE reports
SET created_at = CASE id
    WHEN 'A0000000-0000-0000-0000-000000000001' THEN NOW() - INTERVAL '2 hours'
    WHEN 'A0000000-0000-0000-0000-000000000002' THEN NOW() - INTERVAL '2 days'
    WHEN 'A0000000-0000-0000-0000-000000000003' THEN NOW() - INTERVAL '7 hours'
    ELSE created_at
END;

-- =================================================================
-- UPDATE STATISTICS AND FINAL CLEANUP
-- =================================================================

-- Update word counts for all vocabulary lists
UPDATE vocab_lists SET word_count = (
    SELECT COUNT(*) FROM vocabulary WHERE list_id = vocab_lists.id
);

-- Update user statistics based on actual data
UPDATE user_stats SET 
    total_vocabulary = (
        SELECT COUNT(DISTINCT uwp.word_id) 
        FROM user_word_progress uwp 
        WHERE uwp.user_id = user_stats.user_id
    ),
    total_reviews = (
        SELECT COALESCE(SUM(correct_count + incorrect_count), 0)
        FROM user_word_progress uwp 
        WHERE uwp.user_id = user_stats.user_id
    ),
    correct_reviews = (
        SELECT COALESCE(SUM(correct_count), 0)
        FROM user_word_progress uwp 
        WHERE uwp.user_id = user_stats.user_id
    );

-- Give the demo statistics page strong headline numbers after the raw counters
-- are reconciled from progress rows.
UPDATE user_stats
SET
    total_vocabulary = 128,
    total_reviews = 420,
    correct_reviews = 365,
    current_streak = 14,
    longest_streak = 28,
    last_review_date = CURRENT_DATE,
    total_study_time = 1840,
    updated_at = NOW()
WHERE user_id = '00000000-0000-0000-0000-000000000011';

UPDATE user_stats
SET
    total_vocabulary = 102,
    total_reviews = 318,
    correct_reviews = 274,
    current_streak = 9,
    longest_streak = 17,
    last_review_date = CURRENT_DATE,
    total_study_time = 1265,
    updated_at = NOW()
WHERE user_id = '00000000-0000-0000-0000-000000000012';

-- Insert final migration record
INSERT INTO schema_migrations (version, description) 
VALUES ('999', 'Seed data inserted successfully')
ON CONFLICT (version) DO UPDATE SET
    description = 'Seed data inserted successfully',
    applied_at = NOW();

-- =================================================================
-- VERIFICATION QUERIES (for testing)
-- =================================================================

-- Uncomment these to verify data was inserted correctly:
-- SELECT 'Users' as table_name, COUNT(*) as count FROM users
-- UNION ALL SELECT 'Vocabulary Lists', COUNT(*) FROM vocab_lists
-- UNION ALL SELECT 'Vocabulary Words', COUNT(*) FROM vocabulary
-- UNION ALL SELECT 'Classrooms', COUNT(*) FROM classrooms
-- UNION ALL SELECT 'Assignments', COUNT(*) FROM assignments
-- UNION ALL SELECT 'User Progress', COUNT(*) FROM user_word_progress
-- UNION ALL SELECT 'Sessions', COUNT(*) FROM revision_sessions
-- UNION ALL SELECT 'Notifications', COUNT(*) FROM notifications;

COMMIT;

-- =================================================================
-- SEED DATA SUMMARY
-- =================================================================
-- 
-- Users: 9 total (1 admin, 3 teachers, 5 learners)
-- Vocabulary Lists: 8 total (varying privacy levels and topics)
-- Vocabulary Words: 122 total (distributed across all lists)
-- Examples: 20 sample examples
-- Synonyms: 15 sample synonym relationships
-- Classrooms: 4 total (different teachers and subjects)
-- Assignments: 5 total (past, current, and future)
-- User Progress: Realistic spaced repetition data
-- Sessions: Active and completed learning sessions
-- Demo freshness: dynamic due reviews, recent history, popular counts, monthly statistics
-- Notifications: Various types of system notifications
-- Achievements: User accomplishments and milestones
-- Reports: Sample content reports for moderation
-- Audit Logs: System activity tracking
--
-- Default login credentials (password: "password"):
-- - Admin: admin@vocaboost.com
-- - Teacher 1: teacher1@vocaboost.com (Ms. Sarah Johnson)
-- - Teacher 2: teacher2@vocaboost.com (Mr. David Chen)
-- - Student 1: student1@email.com (Alex Nguyen)
-- - Student 2: student2@email.com (Maria Rodriguez)
-- - Student 5: student5@email.com (Michael Brown, suspended account demo)
-- - etc.
--
-- =================================================================
