# Quick Teams

Rails 8.1 app (importmap + propshaft + tailwindcss-rails, Solid Queue / Solid Cable, Postgres). No Node or Redis needed.

## Local setup

```bash
docker compose up -d            # Postgres 16 on localhost:5433 (postgres/postgres)
bundle install
bin/rails dev:cache             # StimulusReflex refuses to boot without caching in development
bin/rails db:prepare
bin/dev                         # Rails server + Tailwind watcher (Procfile.dev)
```

`config/database.yml` is driven by environment variables (`DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`).
Set `DB_NAME` to give a checkout or worktree its own pair of databases (`${DB_NAME}_development` / `${DB_NAME}_test`).

## Tests

```bash
bin/rails test                  # models, controllers, mailers, jobs, interactors
bin/rails test test/system      # Selenium + Chrome
bundle exec brakeman -q
bundle exec bundle-audit check --update
```

## Deployment

Production and staging need three databases: primary (`DATABASE_URL`), Solid Queue (`QUEUE_DATABASE_URL`) and
Solid Cable (`CABLE_DATABASE_URL`). `bin/render-build.sh` runs `bin/rails db:prepare`, which loads
`db/queue_schema.rb` and `db/cable_schema.rb` into empty databases. The queue/cable URLs fall back to `DATABASE_URL`,
but `db:prepare` cannot set up all three schemas in one fresh database: give each its own database.
The worker process is `bin/jobs start` (see `Procfile`); `bin/rails solid_queue:check` validates its configuration.
On macOS, forked Solid Queue workers segfault inside `pg` unless `PGGSSENCMODE=disable` is set (Linux is unaffected).

See `docs/upgrade-plan.md` for the upgrade history and outstanding human actions.
