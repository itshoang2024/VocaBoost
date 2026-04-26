# Email Templates

This folder contains Handlebars templates used by `backend/src/services/email.service.js`.

## Structure

```text
layouts/
partials/
templates/
vocaboost-logo.png
vocaboost-logo.svg
```

## Implemented Templates

- `verify-email`
- `reset-password`
- `welcome`
- `daily-reminder`
- `classroom-invitation`
- `assignment-notification`
- `achievement-unlocked`

## Development Preview

Use the supported preview command from `backend/package.json`:

```bash
npm run test:preview
```

That command generates local HTML previews through `backend/tests/scripts/preview-templates.js`.

## Integration Notes

- Email links are built from `FRONTEND_URL`
- SMTP credentials come from `SMTP_USER`, `SMTP_PASS`, and `FROM_EMAIL`
- Template compilation and helper registration happen inside `email.service.js`
