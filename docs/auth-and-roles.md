# Auth And Roles

## Overview

Authentication and authorization in VocaBoost span backend route middleware, JWT helpers, Supabase-backed user records, and frontend session handling.

Primary implementation files:

- `backend/src/routes/auth.route.js`
- `backend/src/helpers/jwt.helper.js`
- `backend/src/middlewares/authenticate.middleware.js`
- `backend/src/middlewares/authorize.middleware.js`
- `frontend/src/lib/api.js`
- `frontend/src/services/Auth/authService.js`

## Roles And Account Status

### Roles

- `learner`
- `teacher`
- `admin`

### Account statuses

- `active`
- `pending_verification`
- `inactive`
- `suspended`

Important current behavior:

- `authenticateMiddleware` blocks `inactive`, `suspended`, and `banned` strings. `banned` is checked in code even though it is not part of the database enum.
- `pending_verification` users are allowed through authentication.
- `requireRole('teacher')` additionally checks that the teacher account is `active`.
- Teacher verification submission immediately updates the user record to `role = teacher` and `account_status = pending_verification`.

## Token Model

### Access token

- Signed with `JWT_SECRET`
- Current helper default expiry: 1 day
- Sent in `Authorization: Bearer <token>`

### Refresh token

- Signed with `JWT_REFRESH_SECRET`
- Current helper default expiry: 7 days
- Used by `/api/auth/refresh-token`

### Verification and reset tokens

- Email verification token uses `JWT_SECRET` and expires in 24 hours
- Password reset token uses `JWT_SECRET` and expires in 15 minutes
- Both are tracked in `auth_tokens`

### Invitation token

- Classroom invitation token uses `JWT_SECRET`
- Payload includes classroom-related claims

### Revocation

- Logout blacklists access and refresh tokens in `token_blacklist`
- `verifyTokenWithBlacklist` and `verifyRefreshToken` reject blacklisted tokens
- `users.token_version` exists in the schema for broader invalidation but is not yet enforced in current JWT verification helpers

## Backend Auth Flow

### Register

1. Create the user
2. Create an email-verification token row
3. Send verification email
4. Return access token, refresh token, and `emailVerified: false`

### Login

1. Look up user by email
2. Reject password login for Google-created accounts without `password_hash`
3. Reject suspended or inactive accounts
4. Return access token, refresh token, and minimal user payload

### Verify email

1. Validate token against `auth_tokens`
2. Mark user as verified
3. Mark token as used
4. Return a fresh access token and refresh token

### Logout

1. Read bearer access token
2. Read `refreshToken` from the request body
3. Blacklist both if provided

### Refresh token

1. Validate refresh token
2. Reject blacklisted or invalid refresh tokens
3. Return a new access token

## Authorization Layers

### `authenticateMiddleware`

- Requires a bearer token
- Verifies token and blacklist state
- Loads the user from the database
- Writes `req.user = { userId, email, role, emailVerified }`

### `requireRole(...roles)`

- Requires `req.user`
- Re-reads the user from the database
- Ensures the user role is in the allowed list
- For teachers, also requires `account_status === 'active'`

### `hasClassroomAccess`

Classroom access is not based only on global role:

- admins get full classroom access
- classroom owners are `classRole = teacher`
- joined learners are `classRole = learner`

### `requireClassRole(...roles)`

- Enforces classroom-scoped roles after `hasClassroomAccess`

## Frontend Session Handling

Session state lives primarily in local storage:

- `token`
- `refreshToken`
- serialized `user`

Key frontend behavior:

- `frontend/src/lib/api.js` attaches bearer tokens automatically
- the request interceptor checks token expiry client-side for non-auth routes
- the response interceptor attempts refresh on `401` for non-auth routes
- `frontend/src/services/Auth/authContext.jsx` loads the stored user and checks account status on startup
- failed refresh clears session data and redirects to `/signin`

## Docs To Update If Auth Changes

- `docs/API contracts/auth.md`
- `docs/auth-and-roles.md`
- `docs/setup-and-run.md` if env vars or OAuth URLs change
- `docs/frontend-architecture.md` if provider or interceptor behavior changes
