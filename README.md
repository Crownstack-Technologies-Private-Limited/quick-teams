# Quick Teams

Quick Teams is a multi-tenant Rails app for running a team: people, projects, schedules, timesheets, goals,
surveys and reports, all in one place. Each company signs up as its own account and pays through Stripe.

## Tech stack

| Area | Choice |
|---|---|
| Language / framework | Ruby 4.0.9, Rails 8.1 |
| Database | PostgreSQL 16 |
| Front end | Hotwire (Turbo + Stimulus), ViewComponent, importmap, Propshaft, Tailwind CSS 4 (no Node needed) |
| Background jobs / websockets | Solid Queue, Solid Cable (no Redis needed) |
| Auth | Devise, devise_invitable, pwned (rejects leaked passwords) |
| Multi-tenancy | acts_as_tenant (one tenant per `Account`) |
| Billing | Pay + Stripe |
| Files | Active Storage on S3, image_processing |
| PDFs | wicked_pdf + wkhtmltopdf |
| Other | Draper decorators, Pagy pagination, New Relic |

## Features

### Accounts, sign-in and billing
- Sign-up and sign-in, invitations by email, and a check that rejects passwords known to have leaked.
- Each company is an isolated account; the owner can delete it.
- Stripe subscriptions: checkout, billing portal, success and expired pages.
- User settings: profile, password, avatar and personal preferences.

### Account setup
Admins manage the lists the rest of the app uses: roles, disciplines, skills, jobs, clients, people tags and
statuses, project tags and statuses, survey question categories, ticket statuses and labels, and account-wide
preferences (including notifications).

### People
- Employee directory with filters, search and stats; invite, deactivate and restore people.
- Each profile has: about, schedules, timesheets, goals, todos, feedback, skills, documents, reports, surveys,
  KPIs and culture (both with stats), team, timeline and observed projects.

### Projects
- Create, edit, archive, restore and delete projects, with tags, statuses, clients, filters and stats.
- Each project has: about, schedules, notes, risks, feedback, timesheets, milestones, todos, skills, reports,
  documents, surveys, KPIs, clients, timeline and observers.

### Scheduling, planner and occupancy
- Resource schedule across people and projects.
- Daily and weekly planner with colour-coded job cards.
- Occupancy views for the whole account, by job and by role.

### Timesheets, goals and todos
- Time logging per person and per project, with stats and filters.
- Goals with comments; todos on people and projects.
- Home dashboard with goals and events.

### Spaces
- Discussion spaces with messages and comments; pin, archive and restore spaces.

### Tickets
- Ticket tracker with open and closed views, statuses, labels and comments.

### Surveys and assessments
- Build surveys from questions, options and categories; clone surveys; reusable templates with assignees.
- Assign surveys, take them, preview attempts and see participant and survey stats.
- Submit and download survey reports, including as PDF; quick assessments from a profile.

### Reports
Available under `/report`:
- Timesheets, employees, projects, risks, observers, skills, activities and roles.
- Goals (all and open), KPIs and a performance report.
- Schedules: available now and next month, no schedule, no projects, overburdened, shared, by role.
- Todos: my pending, pending, all pending, recently added, recently finished.
- Status reports with comments and a submit flow.

### Search and archive
- Search people, projects, users, surveys and skills.
- Archive pages for archived projects, deactivated people and archived spaces.

### Email and background jobs
- Notification emails for comments, feedback, goals, messages, schedules, spaces, tickets and todos.
- A weekly activity digest email.
- Cleanup jobs that delete archived projects, deactivated users and old timesheets (see `config/recurring.yml`).

## Local setup

```bash
docker compose up -d            # Postgres 16 on localhost:5433 (postgres/postgres)
bundle install
bin/rails db:prepare
bin/dev                         # Rails server + Tailwind watcher (Procfile.dev)
```

`config/database.yml` is driven by environment variables (`DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`).
Set `DB_NAME` to give a checkout or worktree its own pair of databases (`${DB_NAME}_development` / `${DB_NAME}_test`).

## Running tests

```bash
bin/rails test                  # models, controllers, mailers, jobs, interactors, ViewComponents
bin/rails test test/system      # Selenium + headless Chrome
bundle exec brakeman -q
bundle exec bundle-audit check --update
```

Tests run in parallel: Rails forks one worker per core (at most 8 by default), and each worker gets its own database
(`${DB_NAME}_test-N`, created and loaded automatically) and its own Active Storage directory (`tmp/storage-N`).

| Variable | Effect |
|---|---|
| `PARALLEL_WORKERS=n` | Number of workers. `PARALLEL_WORKERS=1` runs everything serially (use it to debug an order problem). |
| `HEADED=1` | System tests open a visible Chrome instead of headless (combine with `PARALLEL_WORKERS=1` to watch one test). |

Each worker starts its own Chrome and Capybara server on a free port. Failed system tests leave screenshots in `tmp/screenshots`.
Component previews (development only) are at `/rails/view_components`.

## Deployment

Production and staging use one database (`DATABASE_URL`). Solid Queue and Solid Cable keep their tables in it;
they are created by ordinary migrations in `db/migrate`, and `bin/render-build.sh` runs `db:migrate`.
The worker process is `bin/jobs start` (see `Procfile`); `bin/rails solid_queue:check` validates its configuration.
On macOS, forked Solid Queue workers segfault inside `pg` unless `PGGSSENCMODE=disable` is set (Linux is unaffected).
