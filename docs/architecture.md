# Architecture

## System Summary

VocaBoost is a split web application for vocabulary learning and classroom-based review. The system is composed of a React SPA, an Express API, Supabase database/storage, Gmail SMTP delivery, and Google Gemini for AI-assisted vocabulary helpers.

## Runtime Diagram

```text
Browser
  |
  v
Frontend SPA (React + Vite)
  |- routes, pages, hooks, providers
  |- axios client with auth interceptors
  |
  v
Backend API (Express)
  |- routes -> controllers -> services -> models
  |- auth, authorization, uploads, security middleware
  |
  +--> Supabase database
  |     |- users, vocabulary, review, classroom, moderation tables
  |     `- RPC/functions used for reporting and review summaries
  |
  +--> Supabase storage
  |     |- teacher-credentials
  |     `- user-avatars
  |
  +--> Gmail SMTP
  |     `- verification, reset, invitation, and other email templates
  |
  `--> Google Gemini
        `- example generation and missing-field generation
```

## Major Subsystems

### Frontend

- Entry point: `frontend/src/main.jsx`
- Global providers: `frontend/src/AppProviders.jsx`
- Route groups: `frontend/src/routes/`
- Backend integration: `frontend/src/lib/api.js` plus `frontend/src/services/**`
- Styling system: `frontend/src/scss/` plus design tokens

### Backend

- Local entry point: `backend/server.js`
- Vercel entry point: `backend/api/index.js`
- Express app composition: `backend/src/app.js`
- Route registration: `backend/src/routes/index.route.js`
- Shared cross-cutting concerns: auth, authorization, uploads, security, logging, response utils

### Data Layer

- Schema source: `backend/supabase/migrations/*.sql`
- Seed data: `backend/supabase/seed.sql`, `backend/supabase/seed_statistics.sql`
- Query layer: `backend/src/models/*.model.js`

## Core Domain Flows

### Authentication

- Registration creates a user, stores an email-verification token, sends email, and returns access plus refresh tokens.
- Login returns access plus refresh tokens and blocks suspended or inactive accounts.
- Google OAuth redirects back to the frontend with `token`, `refreshToken`, and `isNewUser` query params.
- Logout blacklists provided access and refresh tokens.

### Vocabulary Management

- All vocabulary routes are authenticated.
- Users manage lists and words through `/api/vocabulary`.
- Public-list search is still gated by authentication because `authenticateMiddleware` is applied to the whole router.
- AI helper endpoints generate example sentences and missing word fields.

### Review Sessions

- Review state is stored in `revision_sessions`, `session_word_results`, and `user_word_progress`.
- Sessions can switch to practice mode automatically if no words are currently due.
- Active sessions can be resumed and summarized in batches of 10 words.
- SM-2 style spaced repetition is implemented in `backend/src/services/review.service.js`.

### Classroom Management

- Teachers create classrooms, invite learners, approve joins, and assign vocabulary review work.
- Assignments clone or reference vocabulary data through assignment sublists.
- Classroom access is controlled by the combination of `authenticateMiddleware`, `hasClassroomAccess`, and `requireClassRole`.

### Moderation And Admin

- Admin-only routes handle teacher verification review, report resolution, and user suspension.
- Teachers become `role = teacher` and `account_status = pending_verification` on verification submission, then depend on admin approval.

## Known Constraints And Documentation Notes

- The API contract docs were historically maintained separately from the route files. Route files are now treated as canonical.
- Archived course documents still describe earlier design states and may not match the implementation.
- The vocabulary image-upload controller calls `storageService.uploadWordImage`, but that method is not currently defined in `backend/src/services/storage.service.js`. Treat `/api/vocabulary/upload-image` as an implementation gap until that helper exists.
- Some older comments and docs contain mojibake from encoding drift. Files touched in this pass are normalized to readable English Markdown.

## Change Impact Notes

- Backend route changes usually require matching updates in `docs/API contracts/`, frontend services, and possibly auth or role docs.
- Migration changes usually require updates to `database.md`, affected services/models, and setup notes if new env or storage assumptions are introduced.
- Frontend route changes usually affect auth redirects, deep links from email templates, and provider-level behavior.
