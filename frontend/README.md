# Frontend

The frontend is a React 19 + Vite single-page application for learner, teacher, and admin workflows in VocaBoost.

## Entry Points

- `src/main.jsx`: router creation and bootstrap
- `src/AppProviders.jsx`: provider stack
- `src/lib/api.js`: shared axios client

## Commands

```bash
npm run dev
npm run build
npm run preview
npm run lint
```

## Important Folders

- `src/routes/`: top-level route groups
- `src/pages/`: page-level features
- `src/components/`: reusable UI and workflow components
- `src/services/`: backend integration layer
- `src/hooks/`: reusable client-side workflows
- `src/scss/`: design tokens and feature styles

## Source Of Truth

- route map: `src/routes/*.jsx`
- API behavior: `src/lib/api.js` and `src/services/**`
- environment variables: `.env.example`

See:

- `../docs/frontend-architecture.md`
- `../docs/setup-and-run.md`
- `../docs/API contracts/README.md`

For coding-agent safety rules, also read `../AGENTS.md`.
