# Setup And Run

## Purpose

This runbook explains how to install dependencies, configure environment variables, run both applications locally, and confirm that the local stack is healthy.

## Prerequisites

- Node.js LTS installed locally
- npm available in the shell
- A Supabase project or local Supabase stack
- Gmail SMTP credentials if you want live email sending
- Google OAuth credentials if you want to test Google login
- Gemini API key if you want AI-assisted vocabulary helpers

Note: the exact Node.js version is not pinned in the repository. A current LTS release is recommended.

## Install Dependencies

The repo has no root `package.json`, so install per app:

```bash
cd backend
npm install
cd ../frontend
npm install
```

## Configure Environment Variables

### Backend

Create `backend/.env` from `backend/.env.example`.

Required groups:

- Server: `PORT`, `NODE_ENV`, `LOG_LEVEL`
- Frontend integration: `FRONTEND_URL`
- Supabase: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY`
- Optional DB pooling: `SUPABASE_DB_URL` or `DATABASE_URL`
- JWT: `JWT_SECRET`, `JWT_REFRESH_SECRET`, `JWT_EXPIRE`
- Email: `SMTP_USER`, `SMTP_PASS`, `FROM_EMAIL`
- Google OAuth: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_CALLBACK_URL`
- AI: `GEMINI_API_KEY`, `GEMINI_MODEL`

### Frontend

Create `frontend/.env` from `frontend/.env.example`.

Required variables:

- `VITE_API_BASE_URL`
- `VITE_GOOGLE_AUTH_URL`

## Run Locally

### Backend

```bash
cd backend
npm run dev
```

Local entry point: `backend/server.js`

Expected local API root:

```text
http://localhost:3000
```

Health endpoint:

```text
GET /health
```

### Frontend

```bash
cd frontend
npm run dev
```

The SPA is bootstrapped from `frontend/src/main.jsx` and typically runs on Vite's default localhost port.

## Supabase Options

### Option 1: use an existing cloud project

- Fill the Supabase URL and keys in `backend/.env`
- Skip local CLI startup

### Option 2: use the local Supabase CLI stack

See `backend/supabase/README.md` for the migration workflow. Typical local commands:

```bash
supabase start
supabase db reset
```

Use the generated local URLs and keys to populate `backend/.env`.

## Smoke Checks

### Backend health

```bash
curl http://localhost:3000/health
```

Expect a JSON success response with database connection info.

### Backend tests

```bash
cd backend
npm test
```

### Frontend build

```bash
cd frontend
npm run build
```

## Common Local Workflows

### Preview email templates

```bash
cd backend
npm run test:preview
```

This runs `backend/tests/scripts/preview-templates.js`.

### Frontend lint

```bash
cd frontend
npm run lint
```

## Troubleshooting Shortlist

- If CORS fails, check `FRONTEND_URL` and the allowed-origin list in `backend/src/middlewares/security.middleware.js`.
- If Google OAuth fails, verify `GOOGLE_CALLBACK_URL` matches the provider configuration and deployed/frontend URL.
- If email sending fails in development, the backend can still compile templates, but SMTP actions will not deliver without valid credentials.
- If review or vocabulary data is missing, verify Supabase migrations and seed state.

For detailed fixes, see `docs/troubleshooting.md`.
