# Troubleshooting

## Backend Starts But Frontend Requests Fail

Likely causes:

- `VITE_API_BASE_URL` points to the wrong backend
- backend CORS does not allow the current frontend origin
- backend is not actually reachable on the expected port

Check:

- `frontend/.env`
- `backend/.env`
- `backend/src/middlewares/security.middleware.js`

## `Not allowed by CORS`

The backend allows:

- `process.env.FRONTEND_URL`
- localhost ports `3000`, `3001`, `5173`, `5174`, `5175`

If your frontend origin differs, update the env var or allowed-origin list.

## Google OAuth Redirect Fails

Check:

- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_CALLBACK_URL`
- `FRONTEND_URL`
- frontend `VITE_GOOGLE_AUTH_URL`

Also confirm that the Google Cloud OAuth app uses the same callback URL as `backend/src/config/passport.config.js`.

## Email Templates Work But Emails Do Not Send

`backend/src/services/email.service.js` can compile templates even when SMTP init fails.

Check:

- `SMTP_USER`
- `SMTP_PASS`
- `FROM_EMAIL`
- whether Gmail app-password rules are satisfied

In development, the service may continue without delivery and log the intended recipient instead.

## Supabase Connection Problems

Check:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_KEY`
- optional `SUPABASE_DB_URL` or `DATABASE_URL`

If `/health` reports connection-pool info, verify the pool URL type and limits.

## Sessions Keep Redirecting To `/signin`

Check:

- frontend local storage contains `token`, `refreshToken`, and `user`
- refresh-token endpoint is reachable
- token-expiry logic in `frontend/src/services/Auth/authService.js`
- backend JWT secrets are stable across requests

## Teacher Verification Upload Fails

Accepted file rules are defined in:

- `backend/src/config/multer.config.js`
- `backend/src/config/storage.config.js`

Teacher credentials use the form field `credentials` and allow one file only.

## Vocabulary Image Upload Fails

The route exists at `/api/vocabulary/upload-image`, but the controller calls `storageService.uploadWordImage`, which is not currently implemented in `backend/src/services/storage.service.js`.

Treat this endpoint as incomplete until the storage service adds that helper.

## Review Session Conflicts

Current backend behavior:

- a recent active session for the same list blocks starting a new one
- an older session or one for a different list may be auto-marked `interrupted`
- if no words are due, the backend can switch to practice mode automatically

If review behavior seems odd, inspect `backend/src/services/review.service.js`.
