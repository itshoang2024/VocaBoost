# VocaBoost

VocaBoost is a vocabulary-learning web application built for the HCMUS Introduction to Software Engineering course. The product combines personal vocabulary management, spaced-repetition review, teacher-managed classrooms, and lightweight admin moderation.

This repository is split into two deployable applications:

- `frontend/`: React 19 + Vite single-page application
- `backend/`: Express 5 API backed by Supabase, Gmail SMTP, and Google Gemini

## What The Project Does

VocaBoost supports four primary workflows:

- Learners create and manage vocabulary lists, add words, tag lists, and review progress.
- Learners review words through spaced repetition, flashcards, and fill-in-the-blank sessions.
- Teachers submit verification, create classrooms, invite learners, and assign vocabulary review work.
- Admins review teacher verification requests, moderate reported content, and suspend or unsuspend users.

## Feature Summary

- Email/password authentication plus Google OAuth
- Email verification, password reset, refresh-token flow, logout token blacklisting
- Vocabulary list CRUD, list history, popular lists, tags, word search
- AI-assisted example generation and missing-field generation for vocabulary entries
- Review sessions with batch summaries, resumable sessions, and automatic practice-mode fallback
- Classroom join-by-code, invitations, manual and automatic approval, assignments, learner progress
- Profile editing, daily goal settings, learning statistics
- Admin moderation for teacher requests, reports, and user status changes

## Repository Layout

```text
.
|- backend/                 Express API, services, Supabase config, tests
|- frontend/                React SPA, routes, services, SCSS design system
|- docs/                    Canonical technical documentation plus archived course artifacts
|- pa/                      Archived course deliverables from earlier phases
|- .agent/                  Agent toolkit metadata (not the canonical repo docs)
|- AGENTS.md                Repo-specific guide for coding agents
`- README.md                Human entry point
```

## Quick Start

### 1. Install dependencies

The repository does not have a root package manifest. Install dependencies per application.

```bash
cd backend
npm install
cd ../frontend
npm install
```

### 2. Configure environment files

Copy the examples before running either app:

```bash
cd backend
copy .env.example .env
cd ../frontend
copy .env.example .env
```

Required variables are documented in:

- `backend/.env.example`
- `frontend/.env.example`
- `docs/setup-and-run.md`

### 3. Run the backend

```bash
cd backend
npm run dev
```

Expected local API base URL: `http://localhost:3000`

Health check:

```bash
curl http://localhost:3000/health
```

### 4. Run the frontend

```bash
cd frontend
npm run dev
```

Default local Vite URL: `http://localhost:5173`

## Common Commands

### Backend

```bash
npm run dev
npm run start
npm test
npm run test:preview
```

### Frontend

```bash
npm run dev
npm run build
npm run preview
npm run lint
```

## Documentation Map

Start here if you are working on the codebase:

- `AGENTS.md`: safe-change rules and repo map for coding agents
- `docs/README.md`: documentation index and canonical source rules
- `docs/architecture.md`: end-to-end system overview
- `docs/setup-and-run.md`: environment setup and local workflows
- `docs/database.md`: schema and migration overview
- `docs/auth-and-roles.md`: authentication and authorization behavior
- `docs/API contracts/README.md`: API contract index

## Source Of Truth

For this documentation pass, treat the following as canonical:

- Express routes: `backend/src/routes/*.route.js`
- Backend and frontend commands: `backend/package.json`, `frontend/package.json`
- Environment variables: `backend/.env.example`, `frontend/.env.example`
- Database shape and behavior: `backend/supabase/migrations/*.sql`

Course PDFs and spreadsheets under `docs/requirements`, `docs/test`, `docs/management`, `docs/analysis and design`, and `pa/` are archived artifacts, not the canonical implementation reference.

## Academic Context

This repository was created for:

- Course ID: `CSC13002`
- Course name: `Introduction to Software Engineering`
- Class ID: `23CLC06`
- Group ID: `06`

Group members:

| Student ID | Full name            | Email                      |
| ---------- | -------------------- | -------------------------- |
| 23127048   | Phan The Hoang       | pthoang23@clc.fitus.edu.vn |
| 23127194   | Nguyen Hoang Phi Hung| nhphung23@clc.fitus.edu.vn |
| 23127224   | Nguyen Le Truc Mai   | nltmai23@clc.fitus.edu.vn  |
| 23127305   | Nguyen Hiep Thang    | nhthang23@clc.fitus.edu.vn |
| 23127436   | Phan Hoang Quang Nghi| phqnghi23@clc.fitus.edu.vn |
