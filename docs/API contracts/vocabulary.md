# Vocabulary API Contract

## Base Path

`/api/vocabulary`

## Authentication

All vocabulary routes require a bearer token.

Important note: even public-list search and tags are currently behind authentication because `authenticateMiddleware` is applied to the whole router.

## Endpoints

### List routes

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/lists` | Create a vocabulary list |
| GET | `/my-lists` | Get the current user's lists |
| GET | `/lists/history` | Get the current user's list-view history |
| GET | `/search` | Search public lists |
| GET | `/lists/popular` | Get popular public lists |
| GET | `/lists/:listId` | Get a list by ID |
| PUT | `/lists/:listId` | Update a list |
| DELETE | `/lists/:listId` | Soft-delete a list |

### Word routes

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/lists/:listId/words` | Create one word in a list |
| POST | `/lists/:listId/words-bulk` | Create many words in a list |
| GET | `/lists/:listId/words` | Get words for a list |
| GET | `/words/:wordId` | Get one word by ID |
| GET | `/lists/:listId/words/search` | Search words in a list |
| PUT | `/words/:wordId` | Update a word |
| DELETE | `/words/:wordId` | Delete a word |

### AI helper routes

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/words/:wordId/generate-example` | Generate an example for an existing word |
| POST | `/generate-example` | Generate an example for an unsaved word |
| POST | `/words/:wordId/generate-missing-fields` | Generate missing fields for an existing word |
| POST | `/generate-missing-fields` | Generate missing fields for an unsaved word |

### Tags and uploads

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/tags` | Get all available tags |
| POST | `/upload-image` | Upload an image and optionally attach it to a word |

## Request Notes

### `POST /lists`

```json
{
  "title": "IELTS Unit 1",
  "description": "Optional description",
  "privacy_setting": "private",
  "tags": ["ielts", "academic"]
}
```

Current validator rules:

- `title`: 2 to 100 chars
- `description`: optional, max 500 chars
- `privacy_setting`: `private` or `public`
- `tags`: optional array of existing tag names

### `POST /lists/:listId/words`

Body fields:

- `term` (required)
- `definition` (required)
- `translation` (optional)
- `image_url` (optional URL)
- `exampleSentence` (optional)
- `synonyms` (optional array)

### `POST /lists/:listId/words-bulk`

```json
{
  "words": [
    {
      "term": "analyze",
      "definition": "to examine in detail"
    }
  ]
}
```

### AI helper endpoints

New-word helper routes expect `term`, `definition`, and optional `context`.

Missing-field helper routes also accept optional `currentData`, for example:

```json
{
  "term": "analyze",
  "definition": "to examine in detail",
  "currentData": {
    "translation": "",
    "synonyms": []
  },
  "context": "business"
}
```

## Response Notes

- list queries return `lists` plus pagination metadata when applicable
- word-list queries return `words` plus pagination metadata when applicable
- AI helper routes return generated content under `data.example` or `data.result`
- AI helper failures preserve provider-aware status codes when possible; Gemini quota exhaustion returns HTTP `429` with `details.code = "AI_QUOTA_EXHAUSTED"` and may include `details.retryAfterSeconds`.
- popular lists and history rely on database-side history and view-count behavior

## Important Current Behavior

- list history is backed by `user_list_history`
- popular lists are backed by `view_count`
- list deletion is implemented as soft deletion through `vocab_lists.is_active`
- `PUT /lists/:listId` currently validates the `title` field explicitly; other update fields are handled more loosely by service logic
- the upload route is wired, but the controller currently calls `storageService.uploadWordImage`, which is not implemented in `backend/src/services/storage.service.js`
