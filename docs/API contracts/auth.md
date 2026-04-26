# Auth API Contract

## Base Path

`/api/auth`

This document is the current human-readable summary of the implemented auth routes.

## Authentication Notes

- Most auth routes are public.
- `GET /validate-token` requires a bearer token.
- `POST /logout` expects the current access token in the `Authorization` header and may also receive a `refreshToken` in the JSON body.

## Endpoints

| Method | Path                   | Purpose                                         |
| ------ | ---------------------- | ----------------------------------------------- |
| POST   | `/register`            | Register a new learner or teacher account       |
| POST   | `/login`               | Email/password sign-in                          |
| POST   | `/logout`              | Blacklist current access and refresh tokens     |
| POST   | `/refresh-token`       | Exchange a refresh token for a new access token |
| GET    | `/google`              | Start Google OAuth                              |
| GET    | `/google/callback`     | Finish Google OAuth and redirect to frontend    |
| POST   | `/forgot-password`     | Send reset email if the account exists          |
| POST   | `/reset-password`      | Reset password using a reset token              |
| GET    | `/verify-email/:token` | Verify email address and issue fresh tokens     |
| POST   | `/resend-verification` | Resend the verification email                   |
| POST   | `/get-account-status`  | Read account and verification status by email   |
| GET    | `/validate-token`      | Validate the current bearer token               |

## Request Notes

### `POST /register`

```json
{
  "email": "user@example.com",
  "password": "StrongPass123",
  "role": "learner"
}
```

Current validator only allows `role` values `learner` and `teacher`.

### `POST /login`

```json
{
  "email": "user@example.com",
  "password": "StrongPass123"
}
```

### `POST /logout`

```json
{
  "refreshToken": "optional-refresh-token"
}
```

### `POST /refresh-token`

```json
{
  "refreshToken": "required-refresh-token"
}
```

### `POST /reset-password`

```json
{
  "token": "reset-token",
  "newPassword": "NewStrongPass123"
}
```

### `POST /get-account-status`

```json
{
  "email": "user@example.com"
}
```

## Response Notes

- register returns `user`, `token`, and `refreshToken`
- login returns `user`, `token`, and `refreshToken`
- verify-email returns verified `user`, `token`, and `refreshToken`
- refresh-token returns `{ "token": "<new access token>" }`
- validate-token returns the authenticated user context from middleware

## OAuth Redirect Contract

Successful Google OAuth redirects to:

```text
${FRONTEND_URL}/auth/success?token=<access>&refreshToken=<refresh>&isNewUser=<boolean>
```

Error redirects use:

```text
${FRONTEND_URL}/login?error=<oauth_failed|access_denied|processing_failed|oauth_unconfigured>
```

## Important Current Behavior

- accounts created through Google without a local password cannot use password login
- login blocks suspended and inactive accounts
- logout blacklists tokens instead of just clearing them client-side
- if Google OAuth environment variables are missing, the backend still starts and Google OAuth routes redirect with `oauth_unconfigured`
