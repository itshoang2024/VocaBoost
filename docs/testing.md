# Testing

## Current Automated Commands

### Backend

From `backend/package.json`:

```bash
npm test
npm run test:preview
```

- `npm test` runs Jest
- `npm run test:preview` runs `backend/tests/scripts/preview-templates.js`

### Frontend

There is no automated frontend test runner configured in `frontend/package.json` at the time of writing.

Current validation commands:

```bash
npm run build
npm run lint
```

## Current Test Coverage Reality

- Backend Jest is configured in `backend/jest.config.js`
- Backend test helpers exist in `backend/tests/`
- Frontend relies on build and manual verification rather than automated tests
- Some older docs referenced commands such as `test:watch`, `test:unit`, `test:integration`, and `test:coverage`; those commands are not currently present in `backend/package.json`

## Minimum Smoke Checks

### Backend

```bash
cd backend
npm test
```

### Frontend

```bash
cd frontend
npm run build
```

### Optional runtime checks

- run the backend and request `GET /health`
- run the frontend and manually verify sign-in, vocabulary, review, and classroom navigation

## Manual Scenario Checklist

- register, verify email, sign in, sign out
- create and edit a vocabulary list
- start and end a review session
- preview or send email templates in development if SMTP is configured
- submit teacher verification and inspect profile state
- create a classroom and assign a vocabulary list

## If You Add New Tests

- document the new command here
- add or update module README references if the command becomes part of the normal workflow
- keep `README.md` aligned if the new test command becomes expected for contributors
