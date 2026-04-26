# Backend Tests

This folder contains the current backend test helpers and email-preview tooling.

## Current Supported Commands

From `backend/package.json`:

```bash
npm test
npm run test:preview
```

- `npm test`: runs Jest
- `npm run test:preview`: runs `tests/scripts/preview-templates.js`

For the repo-level testing policy, see `../../docs/testing.md`.

## What Is In This Folder

- `setup.js`: Jest environment setup
- `scripts/preview-templates.js`: generates local HTML previews for email templates
- `temp/email-previews/`: generated preview artifacts

## Important Note

Older documentation referenced commands such as `test:watch`, `test:unit`, `test:integration`, and `test:coverage`. Those commands are not currently present in `backend/package.json`, so they should be treated as future work rather than active workflow.
