# Backend

The backend is an Express 5 API that powers authentication, vocabulary management, review sessions, classrooms, moderation, email delivery, storage, and AI helpers.

## Entry Points

- `server.js`: local Node server
- `api/index.js`: Vercel serverless entry point
- `src/app.js`: shared Express app configuration

## Commands

```bash
npm run dev
npm run start
npm test
npm run test:preview
```

## Important Folders

- `src/routes/`: public endpoints
- `src/controllers/`: HTTP orchestration
- `src/services/`: business logic
- `src/models/`: Supabase query layer
- `src/middlewares/`: auth, authorization, security, uploads
- `src/templates/emails/`: Handlebars email templates
- `supabase/`: migrations, config, and seed data
- `tests/`: Jest setup and email-template preview tooling

## Source Of Truth

- API routes: `src/routes/*.route.js`
- environment variables: `.env.example`
- database schema: `supabase/migrations/*.sql`

See:

- `../docs/backend-architecture.md`
- `../docs/database.md`
- `../docs/API contracts/README.md`

For coding-agent safety rules, also read `../AGENTS.md`.
