# Review API Contract

## Base Path

`/api/review`

## Authentication

All review routes require a bearer token.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/lists/due` | Get lists with due words |
| GET | `/lists/upcoming` | Get lists with upcoming reviews |
| GET | `/due` | Get all due words grouped by list |
| GET | `/lists/:listId/due-words` | Get due words for one owned list |
| GET | `/sessions/status` | Get the current active session, if any |
| GET | `/sessions/:sessionId/batch-summary` | Get summary for the latest completed batch |
| POST | `/sessions/:sessionId/resume` | Resume an existing session |
| POST | `/sessions/start` | Start a review or practice session |
| POST | `/sessions/:sessionId/submit` | Submit the result for a reviewed word |
| POST | `/sessions/:sessionId/end` | End the session and get the final summary |

## Request Notes

### `POST /sessions/start`

```json
{
  "listId": "uuid",
  "sessionType": "flashcard",
  "practiceMode": false
}
```

Allowed `sessionType` values:

- `flashcard`
- `fill_blank`
- `word_association`

### `POST /sessions/:sessionId/submit`

```json
{
  "wordId": "uuid",
  "result": "correct",
  "responseTimeMs": 2500
}
```

Allowed `result` values:

- `correct`
- `incorrect`

## Response Notes

### `GET /sessions/status`

```json
{
  "success": true,
  "message": "Retrieved active session status.",
  "data": {
    "activeSession": {}
  }
}
```

`activeSession` may be `null`.

### `GET /sessions/:sessionId/batch-summary`

Current implementation summarizes batches of 10 completed words and includes:

- `batchNumber`
- `totalBatches`
- `wordsInBatch`
- `correctAnswers`
- `accuracy`
- `words`
- `overallProgress`

### `POST /sessions/:sessionId/end`

Returns a final summary object plus `words` and `batchSummaries`.

## Important Current Behavior

- If the user already has a recent active session for the same list, starting a new one returns a conflict.
- If the user has an older active session or one for a different list, the backend may auto-mark it `interrupted`.
- If no words are due and `practiceMode` is false, the backend automatically starts a practice session using available list words.
- `GET /lists/:listId/due-words` is owner-only; learners cannot use it to inspect other users' lists.
