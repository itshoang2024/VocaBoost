# Backend Architecture

## Entry Points

- `backend/server.js`: local Node server startup
- `backend/api/index.js`: Vercel serverless entry point
- `backend/src/app.js`: Express app composition shared by both runtimes

## Request Lifecycle

```text
HTTP request
  -> security middleware
  -> request logging
  -> passport initialization
  -> route-level middleware
  -> controller
  -> service
  -> model
  -> Supabase
  -> ResponseUtils / ErrorHandler
```

## Module Responsibilities

### `src/routes/`

- Own public URL paths
- Compose middleware in the correct order
- Mount controllers under feature prefixes

### `src/controllers/`

- Read params, query, body, and authenticated user context
- Map domain errors to HTTP responses
- Keep logic thin and defer behavior to services

### `src/services/`

- Implement business flows for auth, vocabulary, review, classroom, moderation, email, AI, and storage
- Coordinate multiple models or external integrations
- Hold the current review-session and classroom-assignment orchestration logic

### `src/models/`

- Encapsulate Supabase queries
- Return database records or query results without HTTP concerns

### `src/validators/`

- Express-validator rules for request bodies and route params
- Use `handleValidationErrors` from `common.validator`

### `src/middlewares/`

- `authenticate.middleware.js`: JWT and user lookup
- `authorize.middleware.js`: role and classroom-scoped access control
- `security.middleware.js`: helmet, CORS, suspicious-pattern logging
- `upload.middleware.js`: multer wrappers for file uploads

## Cross-Cutting Services

### Supabase

- Configured in `src/config/supabase.config.js`
- Uses both anon and service clients
- Optionally supports pooled direct DB connection settings

### Email

- `src/services/email.service.js`
- Compiles Handlebars templates from `src/templates/emails/`
- Uses Gmail SMTP credentials from env vars
- Can still compile templates in development even if SMTP init fails

### Storage

- `src/services/storage.service.js`
- Initializes `teacher-credentials` and `user-avatars` buckets
- Supports teacher credential uploads and avatar uploads
- Does not currently expose `uploadWordImage`, even though the vocabulary controller calls it

### AI

- `src/services/ai.service.js`
- Uses Google Gemini through `@google/genai`
- Generates example sentences and missing vocabulary fields
- Includes retry and simple pacing logic

## Public Route Groups

Mounted from `backend/src/routes/index.route.js`:

- `/api/auth`
- `/api/teacher`
- `/api/user`
- `/api/vocabulary`
- `/api/classroom`
- `/api/review`
- `/api/admin`
- `/health`

## Response Conventions

Use `backend/src/utils/response.js` as the canonical response envelope:

- success: `success`, `message`, optional `data`
- validation failure: `success`, `message`, `details`
- paginated success: `success`, `message`, `data`, `pagination`

## Things To Test After Backend Changes

- route-level auth and role checks
- response envelope and status codes
- frontend service compatibility for changed endpoints
- migration compatibility if models or queries change
- health endpoint if config, Supabase, or middleware changes
