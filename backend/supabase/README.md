# Supabase Workspace

This folder contains the database source of truth for VocaBoost.

## What Lives Here

- `migrations/`: ordered SQL migrations
- `seed.sql`: base seed data
- `seed_statistics.sql`: statistics-related seed data
- `config.toml`: Supabase CLI config

## Canonical Rule

If database behavior is in doubt, trust `migrations/*.sql` over older docs.

## Common Workflows

### Start a local stack

```bash
supabase start
```

### Reset local database and apply migrations

```bash
supabase db reset
```

### Create a new migration

```bash
supabase migration new your_change_name
```

### Push migrations to a linked remote project

```bash
supabase db push
```

## Notes For Contributors

- add new behavior as a new migration instead of rewriting applied migrations
- keep migration descriptions meaningful because the docs reference them
- update `../../docs/database.md` when schema or DB-side behavior changes

## How to reset your database and load seed?

```bash
npx supabase login
npx supabase link --project-ref <your-project-ref>
npx supabase db reset --linked
```

If you don't want to load seed

```bash
npx supabase db reset --linked --no-seed 
```