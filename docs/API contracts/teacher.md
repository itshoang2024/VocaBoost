# Teacher API Contract

## Base Path

`/api/teacher`

## Authentication

All teacher routes require a bearer token.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/verification/submit` | Submit or update a teacher verification request |
| GET | `/verification/status` | Read the current user's verification status |

## Request Notes

### `POST /verification/submit`

Use `multipart/form-data`.

Required text fields:

- `fullName`
- `institution`
- `schoolEmail`

Optional text field:

- `additionalNotes`

Required file field:

- `credentials`

Upload constraints are enforced by multer and storage config:

- one file only
- teacher-document MIME types only
- max file size: 10 MB

## Response Notes

### `POST /verification/submit`

Returns:

- `requestId`
- `status`
- `submittedAt`
- `isUpdate`

Status code:

- `201` for first submission
- `200` for updating an existing request

### `GET /verification/status`

Returns fields such as:

- `status`
- `submittedAt`
- `institution`
- `rejectionReason`
- `message`

If no request exists, the route returns:

```json
{
  "status": "not_submitted",
  "message": "No verification request found"
}
```

## Important Current Behavior

Submitting verification currently:

- uploads the credential file to the `teacher-credentials` bucket
- updates the user's display name if `fullName` is provided
- sets the user's role to `teacher`
- sets `account_status` to `pending_verification`
