# Database

## Source Of Truth

The canonical database definition for VocaBoost is `backend/supabase/migrations/*.sql`.

This document summarizes the schema, enum types, later behavioral migrations, and the compatibility rules that matter when changing the backend.

## Schema Groups

### User And Auth

Base migrations:

- `002_user_management.sql`
- `025_token_blacklist.sql`
- `026_add_token_version.sql`

Main tables:

- `users`
- `user_deactivation`
- `user_settings`
- `user_stats`
- `teacher_requests`
- `auth_tokens`
- `token_blacklist`

Key behavior:

- `users.role` uses `user_role`
- `users.account_status` uses `user_status`
- verification and reset links use `auth_tokens`
- logout and token revocation rely on `token_blacklist`
- `token_version` exists for broader invalidation strategy, even though the current JWT helpers rely primarily on blacklisting

### Vocabulary

Base migrations:

- `003_vocabulary_management.sql`
- `010_update_tables.sql`
- `014_delele_handling.sql`
- `019_user_history.sql`
- `020_popular_list.sql`
- `023_consolidate_foreign_keys.sql`

Main tables:

- `vocab_lists`
- `vocabulary`
- `vocabulary_examples`
- `word_synonyms`
- `tags`
- `list_tags`
- `ai_generations`
- `user_list_history`

Key behavior:

- `vocab_lists.is_active` is the soft-delete flag for lists
- `translation` lives on `vocabulary` after migration `010`
- `vocabulary_examples` is one-to-one with vocabulary after migration `010`
- delete handling cascades to examples, synonyms, and progress
- `user_list_history` plus `view_count` support list history and popular-list behavior
- foreign keys were consolidated in `023` to avoid nested-query ambiguity in Supabase

### Review And Learning

Base migrations:

- `004_learning_system.sql`
- `012_revision_functions.sql`
- `013_add_word_ids_to_sessions.sql`
- `017_upcoming_list_function.sql`
- `018_monthly_progress.sql`

Main tables and helpers:

- `user_word_progress`
- `revision_sessions`
- `session_word_results`
- `monthly_user_stats`
- functions for due lists, upcoming review lists, and progress aggregation

Key behavior:

- `user_word_progress` stores next review date, ease factor, interval, and repetition counts
- `revision_sessions.word_ids` stores the exact set of words used for a session
- batch-summary and resume flows depend on `session_word_results`
- monthly progress uses `monthly_user_stats` and `update_monthly_progress`

### Classroom

Base migrations:

- `005_classroom_system.sql`
- `015_classroom_functions.sql`
- `021_add_notes_to_teacher_requests.sql`

Main tables:

- `classrooms`
- `classroom_members`
- `assignments`
- `assignment_sublists`
- `learner_assignments`
- `classroom_invitations`

Key behavior:

- `classrooms.classroom_status` includes `deleted`, which is used for soft deletion
- `classroom_members.join_status` tracks invite, request, join, and rejection states
- assignments break larger vocabulary sets into assignment sublists
- invitation links are token-based and stored in `classroom_invitations`

### Moderation And Reporting

Base migration:

- `006_system_utilities.sql`

Main tables:

- `reports`
- `audit_logs`
- `notifications`
- `achievements`

These support moderation, auditability, and user-facing status or reward flows.

## Enum Types

Defined in `001_extensions_and_enums.sql`:

- `user_role`: `learner`, `teacher`, `admin`
- `user_status`: `pending_verification`, `active`, `inactive`, `suspended`
- `verification_status`: `pending`, `approved`, `rejected`
- `privacy_setting`: `private`, `public`
- `session_status`: `in_progress`, `completed`, `interrupted`
- `join_status`: `pending_request`, `pending_invite`, `joined`, `rejected`
- `assignment_status`: `not_started`, `in_progress`, `completed`, `late`, `interrupted`
- `report_status`: `open`, `resolved`, `dismissed`
- `token_type`: `email_verification`, `password_reset`
- `classroom_status`: `private`, `public`, `deleted`

## Important Compatibility Rules

- Do not edit already-applied migrations in place for behavior changes. Add a new migration instead.
- If you change foreign-key relationships used by nested Supabase selects, verify nested query behavior in models and document the reason in the migration.
- If you change soft-delete behavior for lists or classrooms, review the search, history, popular-list, and access-control code paths.
- If you change review-session shape, check `revision_sessions.word_ids`, batch summary logic, and active-session resume behavior.
- If you change token or auth tables, update `docs/auth-and-roles.md` and the relevant helper code assumptions.

## Storage-Related Notes

Storage buckets are initialized by backend code, not by SQL migrations:

- `teacher-credentials`
- `user-avatars`

These settings live in `backend/src/config/storage.config.js` and `backend/src/services/storage.service.js`.

## What To Update When Schema Changes

- Add a migration under `backend/supabase/migrations/`
- Update `docs/database.md`
- Update any affected API contract or architecture doc
- Re-check seed compatibility if the change affects local demo data
