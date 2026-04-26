# User API Contract

## Base Path

`/api/user`

## Authentication

All user routes require a bearer token.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/profile` | Get the current user's profile |
| PUT | `/profile` | Update profile fields and optional avatar |
| POST | `/report` | Report a vocabulary word for moderation |
| GET | `/profile/statistics` | Get learning statistics for the current user |

## Request Notes

### `PUT /profile`

Accepted fields:

- `displayName`
- `dailyGoal`
- `removeAvatar`
- optional file field `avatar`

This route can be used as JSON when only updating text fields, or as `multipart/form-data` when uploading an avatar.

### `POST /report`

```json
{
  "wordId": "uuid",
  "reason": "This word contains incorrect or inappropriate content."
}
```

Validation rules:

- `wordId` must be a UUID
- `reason` must be present and be between 5 and 500 characters

## Response Notes

### `GET /profile`

Returns the profile assembled by `userProfileModel.getProfile()` plus additional derived fields such as:

- `teacherVerification` for teacher-role users
- `classroomCount` for teacher-role users
- `vocabularyListCount`

### `GET /profile/statistics`

Returns grouped statistics sections:

- `summaryStats`
- `progressOverTime`
- `completionRates`
- `studyConsistency`

### `POST /report`

```json
{
  "success": true,
  "message": "Word reported successfully. Our team will review it.",
  "data": {
    "reportId": "uuid",
    "status": "open"
  }
}
```
