# API Contract Index

## Source Of Truth

The canonical API surface is defined by:

- `backend/src/routes/*.route.js`
- `backend/src/validators/*.validator.js`
- `backend/src/controllers/*.controller.js`
- `backend/src/utils/response.js`

These Markdown files summarize the current implementation for humans and coding agents. If a route changes, update the matching contract in the same change.

## Response Envelope

Most endpoints use these JSON envelopes:

### Success

```json
{
  "success": true,
  "message": "Optional status message",
  "data": {}
}
```

### Validation failure

```json
{
  "success": false,
  "message": "Validation failed",
  "details": []
}
```

### General failure

```json
{
  "success": false,
  "message": "Error message"
}
```

## Contract Files

- [auth.md](auth.md)
- [user.md](user.md)
- [teacher.md](teacher.md)
- [vocabulary.md](vocabulary.md)
- [review.md](review.md)
- [classroom.md](classroom.md)
- [admin.md](admin.md)

## Maintenance Checklist

- route path changed -> update this folder
- request validation changed -> update request-field notes
- response shape or status code changed -> update examples or response notes
- frontend service usage changed -> check the consuming service under `frontend/src/services/`
