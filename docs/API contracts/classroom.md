# Classroom API Contract

## Base Path

`/api/classroom`

## Authentication And Access Model

All classroom routes require a bearer token.

Route access is determined by:

- `authenticateMiddleware`
- `hasClassroomAccess`
- `requireClassRole(...)`

Current classroom-scoped roles:

- `teacher`: classroom owner
- `learner`: joined learner in the classroom
- `admin`: global admin with classroom access

## Endpoint Summary

### Classroom creation and membership

| Method | Path | Role | Purpose |
| --- | --- | --- | --- |
| POST | `/create-classroom` | active teacher | Create a classroom |
| GET | `/my-classrooms` | active teacher | Get classrooms owned by the current teacher |
| POST | `/join-request` | authenticated user | Join by join code |
| GET | `/:classroomId/join-requests` | teacher | Get pending join requests |
| POST | `/:classroomId/approve-request` | teacher | Approve one join request |
| POST | `/:classroomId/reject-request` | teacher | Reject one join request |
| POST | `/:classroomId/approve-all` | teacher | Approve all pending requests |
| GET | `/:classroomId/learners` | teacher/admin/joined learner | Get joined learners |
| POST | `/:classroomId/remove-learner` | teacher | Remove a learner |
| DELETE | `/:classroomId` | teacher or admin | Soft-delete a classroom |
| GET | `/:classroomId/search-learners` | classroom member | Search learners by status and display name |
| GET | `/my-joined` | authenticated user | Get classrooms the current user has joined |
| POST | `/:classroomId/leave` | learner | Leave a classroom |

### Invitations

| Method | Path | Role | Purpose |
| --- | --- | --- | --- |
| POST | `/:classroomId/invitation` | teacher | Invite a learner by email |
| POST | `/accept-invitation` | authenticated user | Accept an invitation token |
| DELETE | `/:classroomId/invitation` | teacher | Cancel an invitation |
| GET | `/:classroomId/invitations` | teacher | List classroom invitations |

### Assignments

| Method | Path | Role | Purpose |
| --- | --- | --- | --- |
| POST | `/:classroomId/assignment` | teacher | Create an assignment |
| GET | `/:classroomId/assignments` | teacher | List classroom assignments |
| GET | `/:classroomId/assignments/to-review` | learner | Get learner assignments to review |
| GET | `/:classroomId/assignments/reviewed` | learner | Get completed learner assignments |
| GET | `/:classroomId/assignments/overdue` | learner | Get overdue learner assignments |
| GET | `/:classroomId/:assignmentId` | teacher | Get assignment details |
| DELETE | `/:classroomId/:assignmentId` | teacher | Delete an assignment |
| GET | `/:classroomId/assignment/:assignmentId/vocab-list/:subListId` | learner | Get one assignment sub-vocabulary list |

### Classroom settings

| Method | Path | Role | Purpose |
| --- | --- | --- | --- |
| PATCH | `/:classroomId/auto-approve` | teacher | Enable or disable auto-approval |

## Important Request Notes

### `POST /create-classroom`

Required fields:

- `name`
- `classroom_status`: `private` or `public`
- `capacity_limit`: integer `1..100`

Optional:

- `description` up to 1000 chars

### `POST /join-request`

```json
{
  "joinCode": "ABC123"
}
```

### `POST /:classroomId/approve-request`

```json
{
  "learnerId": "uuid"
}
```

The same `learnerId` body shape is used by reject and remove actions.

### `POST /:classroomId/invitation`

```json
{
  "email": "student@example.com"
}
```

### `POST /accept-invitation`

```json
{
  "token": "invitation-token"
}
```

### `POST /:classroomId/assignment`

Required fields:

- `vocabListId`
- `title`
- `exerciseMethod`: `flashcard`, `fill_blank`, or `word_association`
- `wordsPerReview`: integer `5..30`
- `startDate`: ISO 8601 datetime
- `dueDate`: ISO 8601 datetime

Validation also enforces:

- `wordsPerReview` cannot exceed the number of words in the selected list
- `dueDate` cannot be in the past
- `dueDate` must be equal to or after `startDate`

### `PATCH /:classroomId/auto-approve`

```json
{
  "isAutoApprovalEnabled": true
}
```

## Important Response Notes

- create-classroom and create-assignment return `201`
- join by code returns different success messages depending on auto-approval
- `GET /:classroomId/:assignmentId` returns assignment metadata plus vocabulary content for teacher review
- `GET /:classroomId/assignment/:assignmentId/vocab-list/:subListId` returns the nested `result.data` payload from the classroom service

## Important Current Behavior

- classroom deletion is modeled through `classroom_status = deleted`
- invitation acceptance depends on the authenticated user's account matching the invitation email
- learner assignment progress is tracked separately from review sessions
