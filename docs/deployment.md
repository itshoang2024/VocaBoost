# Deployment

## Deployment Shape

VocaBoost is deployed as two separate Vercel applications:

- backend: Node serverless function from `backend/api/index.js`
- frontend: static Vite build from `frontend/dist`

## Backend Deployment

Source file: `backend/vercel.json`

Current behavior:

- Vercel builds `api/index.js` with `@vercel/node`
- all backend requests are routed to that entry point
- `backend/src/app.js` is the shared Express app

Required backend env groups:

- `FRONTEND_URL`
- Supabase keys and optional DB pool settings
- JWT secrets
- SMTP credentials
- Google OAuth credentials if Google sign-in is enabled
- Gemini API credentials

## Frontend Deployment

Source file: `frontend/vercel.json`

Current behavior:

- Vercel runs `npm run build`
- output directory is `dist`
- all routes rewrite to `index.html`

Required frontend env vars:

- `VITE_API_BASE_URL`
- `VITE_GOOGLE_AUTH_URL`

## Deployment Compatibility Notes

- `FRONTEND_URL` must match the frontend deployment URL for CORS, email links, and OAuth redirects.
- `GOOGLE_CALLBACK_URL` must match the backend deployment callback URL configured in Google Cloud.
- If any `GOOGLE_*` OAuth variable is missing, the backend still boots, but Google OAuth routes redirect with `oauth_unconfigured`.
- The frontend expects the backend API under `${VITE_API_BASE_URL}/api`.
- Local runtime uses `backend/server.js`, but Vercel uses `backend/api/index.js`.

## Post-Deploy Checks

- request backend `GET /health`
- verify frontend loads without blank-route failures
- verify sign-in and token refresh behavior
- verify email links point to the correct frontend domain
- verify CORS allows the deployed frontend origin
