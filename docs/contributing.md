# Contributing

## Working Model

VocaBoost is a split frontend/backend repository with Supabase-managed schema migrations. Contributors should make small, source-of-truth-aligned changes and update docs in the same branch.

## Branch And Change Guidelines

- keep changes scoped to the subsystem you are editing
- avoid mixing schema, API, and broad frontend refactors unless they are tightly related
- prefer adding migrations over changing applied migrations
- keep route, env, and documentation changes in sync

## Required Documentation Updates

### If you change backend routes

- update the matching file under `docs/API contracts/`
- update `docs/backend-architecture.md` if the route group or layering changes
- update frontend services or route docs if the frontend consumes the change

### If you change schema or Supabase functions

- add a migration under `backend/supabase/migrations/`
- update `docs/database.md`
- update any contract doc whose payload or behavior changes

### If you change auth or role behavior

- update `docs/auth-and-roles.md`
- update `docs/API contracts/auth.md`
- review frontend auth flow assumptions in `docs/frontend-architecture.md`

### If you add or rename env vars

- update the appropriate `.env.example`
- update `docs/setup-and-run.md`
- update `docs/deployment.md` if the variable matters in Vercel

## Verification Before Opening A PR

- run `npm test` in `backend`
- run `npm run build` in `frontend`
- run any subsystem-specific manual checks for your change
- confirm that docs do not claim commands or env vars that do not exist

## Archived Artifacts

Do not treat the archived course documents as the implementation authority. Keep them for history, but use code, migrations, and the docs in this folder as the current reference set.
