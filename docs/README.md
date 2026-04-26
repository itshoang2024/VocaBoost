# Documentation Index

This folder contains the canonical technical documentation for VocaBoost plus archived academic deliverables from the course project.

## Canonical Docs

Use these files when working on the current codebase:

- [architecture.md](architecture.md): end-to-end system overview
- [setup-and-run.md](setup-and-run.md): local setup, environment, and common workflows
- [database.md](database.md): Supabase schema and migration overview
- [auth-and-roles.md](auth-and-roles.md): authentication, account status, and authorization model
- [backend-architecture.md](backend-architecture.md): Express application structure
- [frontend-architecture.md](frontend-architecture.md): React application structure
- [testing.md](testing.md): current test commands and test expectations
- [deployment.md](deployment.md): Vercel deployment layout and environment requirements
- [troubleshooting.md](troubleshooting.md): common failure modes
- [contributing.md](contributing.md): contribution and documentation update rules
- [API contracts/README.md](API%20contracts/README.md): API contract index

## Archived Course Artifacts

These files are useful for historical context, but they are not the source of truth for the running application:

- `docs/requirements/`
- `docs/test/`
- `docs/management/`
- `docs/analysis and design/`
- `pa/`

## Source Of Truth Rules

When docs conflict with code, verify these first:

- `backend/src/routes/*.route.js` for API endpoints
- `backend/src/validators/*.validator.js` for request validation
- `backend/src/services/*.service.js` for behavior and side effects
- `backend/supabase/migrations/*.sql` for schema and RPC behavior
- `backend/.env.example` and `frontend/.env.example` for environment variables
- `backend/package.json` and `frontend/package.json` for supported commands
- `frontend/src/routes/*.jsx` and `frontend/src/lib/api.js` for frontend route and API usage

## Documentation Maintenance Rules

- If a route changes, update the matching contract doc under `docs/API contracts/`.
- If an environment variable changes, update the relevant `.env.example` file and `setup-and-run.md`.
- If a migration changes data shape or behavior, update `database.md`.
- If a frontend route, redirect, or provider changes, update `frontend-architecture.md`.
- If a command changes, update `README.md`, `testing.md`, and any module README that references it.
