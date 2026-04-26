# Frontend Source Map

This directory contains the React application source code.

## Main Areas

- `main.jsx`: app bootstrap and router assembly
- `AppProviders.jsx`: global provider composition
- `routes/`: top-level route groups
- `pages/`: page-level features
- `components/`: reusable UI and domain components
- `services/`: backend integration wrappers
- `hooks/`: reusable client-side workflows
- `constants/`: design tokens and shared constants
- `scss/`: styling system

## Read This With

- `../../docs/frontend-architecture.md`
- `../../docs/API contracts/README.md`
- `../../AGENTS.md`

## Change Guidance

- route changes should be reflected in the frontend architecture doc if they affect navigation or deep-link expectations
- API usage changes should stay aligned with the matching backend contract docs
