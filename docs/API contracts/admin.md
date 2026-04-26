# Admin API Contract

## Base Path

`/api/admin`

## Authentication

All admin routes require:

- bearer authentication
- `requireAdmin`

This file documents the implemented admin routes even though the original repository did not previously include a dedicated admin contract document.

## Endpoints

### Teacher verification moderation

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/teacher-requests/pending` | Get pending teacher verification requests |
| GET | `/teacher-requests/:requestId` | Get one teacher request |
| PUT | `/teacher-requests/:requestId/approve` | Approve a teacher request |
| PUT | `/teacher-requests/:requestId/reject` | Reject a teacher request |

### Content moderation

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/reports/open` | Get open reports |
| GET | `/reports/:reportId` | Get one report |
| PUT | `/reports/:reportId/approve` | Resolve a report and remove associated content |
| PUT | `/reports/:reportId/dismiss` | Dismiss a report and keep the content |

### User management

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/users` | Get users with pagination and optional search |
| PUT | `/users/:userId/ban` | Suspend a user |
| PUT | `/users/:userId/unban` | Remove user suspension |

## Request Notes

### Teacher request lookups

`requestId` must be a UUID.

### Report moderation

`reportId` must be a UUID.

Approve and dismiss actions expect:

```json
{
  "notes": "Why this moderation decision was taken"
}
```

### User suspension

Optional body:

```json
{
  "reason": "Optional suspension reason"
}
```

## Important Current Behavior

- report approval resolves the report and removes associated content through the service layer
- report dismissal resolves the report without removing the content
- teacher-request rejection currently does not expose a request-body reason in the route contract, even though there is a validator helper for rejection reasons in `admin.validator.js`
