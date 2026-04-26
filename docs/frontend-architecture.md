# Frontend Architecture

## Entry Points

- `frontend/src/main.jsx`: router creation and app bootstrap
- `frontend/src/AppProviders.jsx`: provider composition
- `frontend/src/lib/api.js`: shared axios client

## Route Groups

The SPA route map is assembled from `frontend/src/routes/*.jsx`.

### Auth routes

Defined in `frontend/src/routes/AuthRoutes.jsx`:

- landing page, sign-in, sign-up
- verify email, forgot/reset password
- Google OAuth success handling
- teacher verification entry points

### Vocabulary routes

Defined in `frontend/src/routes/VocabularyRoutes.jsx`:

- dashboard
- create list
- edit list
- view list
- overview list

### Classroom routes

Defined in `frontend/src/routes/ClassroomRoutes.jsx`:

- create, join, and view classroom pages
- teacher management layout and sub-pages
- assignment review and overview deep links

### Review routes

Defined in `frontend/src/routes/Review.Routes.jsx`:

- standard review
- flashcard sessions
- fill-in-the-blank sessions
- batch summary and final summary pages

### User and admin routes

- `frontend/src/routes/UserRoutes.jsx`
- `frontend/src/routes/AdminRoutes.jsx`

## Provider Stack

`frontend/src/AppProviders.jsx` composes:

- `StrictMode`
- `ErrorBoundary`
- `AuthProvider`
- `ConfirmProvider`
- `ToastProvider`

This means auth, confirm modal, and toast behavior are globally available to pages and components.

## API And Session Model

### Shared client

`frontend/src/lib/api.js`:

- builds requests from `VITE_API_BASE_URL`
- attaches bearer tokens from local storage
- performs client-side token expiry checks
- retries unauthorized requests once through refresh-token flow
- clears session and redirects to `/signin` when refresh fails

### Auth state

`frontend/src/services/Auth/authContext.jsx`:

- loads the persisted user on startup
- checks account status from the backend
- marks pending email-verification state in session storage

`frontend/src/services/Auth/authService.js`:

- owns login, logout, register, verify-email, refresh-token, and session helpers

## Feature Organization

- `src/pages/`: page-level feature entry points
- `src/components/`: reusable visual and workflow components
- `src/services/`: feature-specific HTTP wrappers
- `src/hooks/`: custom hooks for feature workflows and UI behavior
- `src/constants/`: shared constants and design-token exports
- `src/utils/`: helper utilities for auth, validation, navigation, and dev-only behavior

## Styling System

- global SCSS entry: `frontend/src/scss/main.scss`
- design tokens: `_DesignTokens.scss`, `_ComponentTokens.scss`, `_CSSVariables.scss`
- feature styles: `Auth`, `User`, `Vocabulary`, `Classroom`, `Review`, `Admin`

The SCSS README is now a local reference, while `docs/frontend-architecture.md` is the canonical architecture overview.

## Things To Test After Frontend Changes

- affected route paths and navigation
- auth redirects and session recovery
- feature services that depend on changed backend contracts
- loading, error, and empty states for edited pages
- build output via `npm run build`
