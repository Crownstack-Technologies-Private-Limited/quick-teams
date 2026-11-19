# Quick Teams — Upgrade Plan

_Prepared 2026-11-18 on branch `upgrade` (tip `9636210e`, "fix tests", 2025-12-05)._

## 1. Where we are

| | `dev` (production line) | `upgrade` branch (today) | Target (latest) |
|---|---|---|---|
| Ruby | 3.3.0 | 3.4.7 | **4.0.9** |
| Rails | 7.1.3.2 (security support ended Oct 2025) | 8.1.1 | **8.1.4.1** |
| Assets | esbuild + Tailwind 3 CLI (Node 22 + Yarn) | importmap + propshaft + tailwindcss-rails 4 (**no Node**) | same |
| Jobs / cable / sessions | Sidekiq + Redis | Solid Queue + Solid Cable (**no Redis**) | same |
| Database | Postgres | Postgres | Postgres 16 |

The `upgrade` branch already contains most of the hard work (Rails 8.1, importmap, Solid Queue/Cable, Tailwind 4,
Alpine → Stimulus, feature removals). The plan below is: **make `upgrade` correct, reconcile it with `dev`, then move
each dependency to latest in small, separately-deployable steps.**

### Verified locally on the `upgrade` branch

- Boots on Ruby 3.4.7 against Postgres 16 (Docker, see `docker-compose.yml`); sign-in/sign-up pages render (200).
- `bin/rails test` (models, controllers, mailers, jobs, interactors): **120 runs, 0 failures, 0 errors**.
- `bin/rails test test/system` (Selenium/Chrome): **855 runs, 31 failures, 231 errors**. Breakdown of the errors:
  127 `ActionController::UnknownFormat` (forms submitted as HTML instead of Turbo Stream), 59 `Capybara::ModalNotFound`
  (`data-turbo-confirm` dialogs never appear), ~24 routing / `ActionNotFound 'show'` (`data-turbo-method: :delete`
  links fall back to GET), 43 `ElementNotFound` (dropdowns/modals never open). Nearly all of them trace back to the
  broken JS in §3.1. Separately, Chrome's `/favicon.ico` request 404s in ~160 tests (noise: add `public/favicon.ico`).
- In the browser **no JavaScript runs at all** (`window.Turbo` and `window.Stimulus` are undefined).

## 2. Ground rules

- One PR per step below; each step must leave the app deployable and the full suite (unit **and** system) green.
- Bump gems with `bundle update <gem> --conservative`; never a blanket `bundle update`.
- Run `bin/rails test`, `bin/rails test test/system`, `bundle exec brakeman`, `bundle exec bundle-audit` in CI on every PR (see §8).
- Take a production DB backup before any step that has a migration marked **irreversible**.

---

## 3. Phase 0 — Fix what is broken on `upgrade` today (blockers, do before anything else)

These are bugs that exist on the branch right now, independent of further version bumps.

> **Done on `upgrade-base`:** §3.1 (relative imports → importmap names; also the slim-select pin pointed at a jspm
> URL that 404s and aborted the whole module graph — now jsdelivr), the §3.2 JS pin (`stimulus_reflex@3.5.5`), and the
> committed ENV-driven `config/database.yml` from §3.5 (local DB name is `${DB_NAME:-quickteams}_development|_test`).
> Turbo, all Stimulus controllers and StimulusReflex now load with no failed requests.

### 3.1 JavaScript module graph never loads — P0
The code still uses esbuild-style relative imports, which importmap cannot resolve (404 for every bare path, so the whole
module graph aborts: no Turbo, no Stimulus controllers, no StimulusReflex).

| File | Change |
|---|---|
| `app/javascript/application.js:9` | `import "./trix-editor-overrides"` → `import "trix-editor-overrides"` and add `pin "trix-editor-overrides"` to `config/importmap.rb` |
| `app/javascript/controllers/index.js:4-39` | `"./application"` → `"controllers/application"`, `"./x_controller"` → `"controllers/x_controller"` (or replace the hand-written list with `eagerLoadControllersFrom("controllers", application)` from `@hotwired/stimulus-loading`) |
| `app/javascript/controllers/application.js:2`, `config/cable_ready.js:1` | `"../channels/consumer"` → `"channels/consumer"` |
| `app/javascript/config/index.js:1-2` | `'./cable_ready'` → `'config/cable_ready'`, `'./stimulus_reflex'` → `'config/stimulus_reflex'` |
| `app/javascript/config/stimulus_reflex.js:1-2` | `"../controllers/application"` → `"controllers/application"`, same for `application_controller` |

Acceptance: no 404s in the browser console; `window.Stimulus.router.modules` lists every controller; re-run system tests
and triage what is left.

### 3.2 StimulusReflex JS/gem version mismatch — P0
`config/importmap.rb:23` pins `stimulus_reflex@3.5.2` while the gem is 3.5.5. With the default
`on_failed_sanity_checks = :exit` every reflex raises `VersionMismatchError`.
Fix: pin `https://ga.jspm.io/npm:stimulus_reflex@3.5.5/dist/stimulus_reflex.js` (cable_ready 5.0.6 already matches).
Also: the test env uses `:null_store`, so the sanity check aborts `rails test` unless `SKIP_SANITY_CHECK=true` is set —
set `config.on_failed_sanity_checks = :warn` when `Rails.env.test?` (or use `:memory_store` in test).
Development needs `bin/rails dev:cache` once (document in README).

### 3.3 Billing schema is three Pay majors behind — P0
`db/schema.rb` has Pay tables at the **Pay 6** level, but the lockfile is on Pay 11.4. The Pay 7/8/10 migrations were never
added. Pay 11 queries `pay_customers.type` and `stripe_account` in `set_payment_processor`
(`pay-11.4.0/lib/pay/attributes.rb`), so:
- `SignUp#set_stripe_subscription_trial` (`app/interactors/sign_up.rb:104-108`) raises `PG::UndefinedColumn`, and
  `SignUp#call` swallows it (`rescue StandardError`) — **new accounts are created without a trial subscription, silently.**
- Checkout / billing portal and webhook syncs fail for the same reason.
- `app/controllers/purchase/billings_controller.rb:6` calls `payment_processor.customer`, removed in Pay 8 (`NoMethodError`). Delete the line.

Migrations (in this order):
1. Hand-written Pay 7 columns:
   ```ruby
   add_column :pay_customers, :stripe_account, :string
   add_column :pay_subscriptions, :stripe_account, :string
   add_column :pay_payment_methods, :stripe_account, :string
   add_column :pay_charges, :stripe_account, :string
   add_column :pay_subscriptions, :payment_method_id, :string
   ```
2. `bin/rails pay:install:migrations` — copies `add_pay_sti_columns` (adds STI `type` columns, renames
   `pay_payment_methods.type` → `payment_method_type`, backfills `type` from `processor`; add
   `reset_column_information` calls before its backfill loop) and `add_object_to_pay_models` (jsonb `object` columns).
3. `test/fixtures/pay/customers.yml`: add `type: Pay::Stripe::Customer` to each fixture.
4. Stop swallowing errors in `SignUp#call` (log + report, or re-raise) and add a test that a sign-up creates a
   `Pay::FakeProcessor::Customer` with a subscription.

Before writing these, confirm what production actually has: `bin/rails runner 'p Pay::Customer.column_names'`.

### 3.4 Solid Queue worker crash-loops — P0
`config/recurring.yml:23-26` schedules `DeleteAccountsJob`, which has never existed. Solid Queue validates recurring tasks
at start-up and the supervisor exits, so **no background jobs run in production (including all `deliver_later` mail).**
- Replace with the job that was dropped in the Sidekiq → Solid Queue move: `class: DeleteArchivedProjectsJob` (daily at midnight, as in the old `sidekiq_scheduler.yml`).
- Add the standard cleanup task: `SolidQueue::Job.clear_finished_in_batches(sleep_between_batches: 0.3)` every hour.
- Delete dead `config/solid_queue.yml` (Solid Queue only reads `config/queue.yml`); add a `staging:` key to `queue.yml`.
- Decide the schedule time zone (Solid Queue ≥ 1.5 uses `config.time_zone`, currently unset = UTC).

### 3.5 Production/staging database and cable config — P0
- `production.rb:58` and `cable.yml` need `queue` and `cable` databases, but `config/database.yml` is gitignored and
  there is no sample. Commit an ENV-driven `config/database.yml` (remove it from `.gitignore`):
  ```yaml
  production:
    primary: &prod
      <<: *default
      url: <%= ENV["DATABASE_URL"] %>
    queue:
      <<: *prod
      url: <%= ENV.fetch("QUEUE_DATABASE_URL") { ENV["DATABASE_URL"] } %>
      migrations_paths: db/queue_migrate
    cable:
      <<: *prod
      url: <%= ENV.fetch("CABLE_DATABASE_URL") { ENV["DATABASE_URL"] } %>
      migrations_paths: db/cable_migrate
  staging: # same three entries
  ```
- Staging: add `config.solid_queue.connects_to = { database: { writing: :queue } }` to `staging.rb`, and a `staging:`
  block to `cable.yml` (today it falls back to the Redis adapter, pointing at a Redis that no longer exists).
- `bin/render-build.sh`: `rake db:migrate` → `bin/rails db:prepare` (loads `queue_schema.rb` / `cable_schema.rb` into empty DBs);
  add `bin/rails solid_queue:check`.
- `Procfile`: `worker: bin/jobs start` (or run jobs in Puma with `SOLID_QUEUE_IN_PUMA=1` + `plugin :solid_queue`).
- Infra: provision the queue/cable databases, remove Redis add-ons and `REDIS_URL`, keep `RAILS_SERVE_STATIC_FILES`.

### 3.6 Smaller live bugs — P1
| Issue | Fix |
|---|---|
| New Relic license key committed in `config/newrelic.yml` | **Rotate the key**, read it from `NEW_RELIC_LICENSE_KEY` |
| Dev mail delivery raises (`development.rb` uses `:letter_opener_web`, gem not in Gemfile) | Add `letter_opener_web` to the dev group, or switch to `:letter_opener` |
| Pagination limits ignored: all 48 `items:` args are dropped by Pagy 9 (renamed to `limit:`) — every list shows 20 | Rename `items:` → `limit:` (fixed for good in §5.1) |
| Array collections never paginate (`Array#count(:all)` is 0) in `report/skills`, `report/observers`, `report/schedules#no_projects`, `project/todos`, `employee/todos` | Handled in the Pagy rewrite (§5.1) |
| `?page=999` / `?page=abc` → 500 (Pagy errors not rescued) | Fixed by Pagy 43 defaults (§5.1) |
| `SubscriptionManager` (`app/models/subscription_manager.rb:12-18`) uses a stale nil `payment_processor` after `set_payment_processor` | `payment_processor = user.set_payment_processor(:stripe)` |
| Text invitation email omits `script_name` (`devise/mailer/invitation_instructions.text.erb:3`) — not verified | Match the HTML template |
| `RegistrationsController#show_errors` only responds to `turbo_stream` | Add an `html` fallback |
| `dump.rdb` (Redis dump) tracked in git | `git rm`, add to `.gitignore` |
| Dead code: `config/initializers/active_storage.rb` patch (method gone in 8.1.4), `config/spring.rb`, non-existent autoload paths in `application.rb:24-25`, `cache_classes` in `staging.rb:7` | Delete / modernise |
| `bin/dev` runs only `rails server`, Tailwind watcher never runs | Use `foreman start -f Procfile.dev` or `plugin :tailwindcss` in Puma |

---

## 4. Phase 1 — Reconcile `upgrade` with `dev`

`upgrade` forked from `dev` on 2023-09-27; `dev` has 50 commits that `upgrade` does not. Most are dependency bumps that
`upgrade` supersedes, but these must be ported:

- **"Quick Teams" rename**: page `<title>` (`layouts/application.html.erb`), mailer subjects (`app/mailers/*`), `app/assets/images/logo.svg`, devise view copy, `config/locales/devise*.yml`, related mailer tests.
- **Health check route** `get "up" => "rails/health#show"` (`config/routes.rb`) — likely used by the load balancer.
- **Puma worker count** from `WEB_CONCURRENCY` in production (`config/puma.rb`).
- YJIT initializer — not needed (Rails 8 enables YJIT by default via `load_defaults`).
- The three Active Storage migrations (`20230930133218..20`) are already reflected in `upgrade`'s schema; production
  has run them. Keep the files so `db:migrate:status` stays clean.

Product sign-off needed — `upgrade` **removes features and data**:
- `20251204145029_drop_nuggets_tables.rb` and `20251204151100_drop_kbs_table.rb` drop `nuggets`, `nuggets_users`, `kbs`.
  **Irreversible data loss** (the `down` recreates empty tables). Export the data first if anyone may need it.
- The `transfer_data_to_admin` preference backfill was commented out.

Merge strategy: merge `dev` into `upgrade` (resolve in favour of `upgrade` for Gemfile/lock/JS tooling), then PR `upgrade` → `dev`.

---

## 5. Phase 2 — Dependency upgrades with code changes

### 5.1 Pagy 9.4 → 43.8 (full API rewrite)
- Delete `include Pagy::Frontend` (`app/helpers/application_helper.rb:2`) and every `include Pagy::Backend`
  (surveys, employees, spaces, schedules, report/base, survey/attempts, survey/base, space/base, project/base, employee/base controllers); add `include Pagy::Method` once in `BaseController`.
- Rewrite `BaseController#pagy_nil_safe`:
  ```ruby
  def pagy_nil_safe(_params, collection, **options)
    options[:limit] = [collection.size, 1].max if collection.is_a?(Array) # keep current one-page behaviour for arrays
    pagy(:offset, collection, **options)
  end
  ```
- Rename `items:` → `limit:` at all 48 call sites (leave `line_items:` in `purchase/checkouts_controller.rb` alone).
- `app/views/shared/_paginator.html.erb`: `pagy_anchor(pagy)` → `pagy.send(:a_lambda)`, `pagy.prev` → `pagy.previous`,
  `pagy.series` → `pagy.send(:series)`, `pagy_url_for(pagy, pagy.next)` → `link.(pagy.next, ...)`; drop the wrong `aria-disabled="true"` on Next.
- Infinite scroll (`infinite_scroll_controller.js`) keeps working (still finds `a[rel='next']`).

### 5.2 Devise 4.9 → 5.0, devise-pwned_password, devise_invitable
- `devise-pwned_password 0.1.12` pins `devise ~> 4` and blocks the upgrade. The app only uses the `not_pwned: true`
  validator (`app/forms/sign_up_form.rb:7`, `change_password_form.rb:7`), which comes from `pwned` → replace with `gem "pwned", "~> 2.4"`.
- Devise 5 derives its key from `Rails.application.secret_key_base` (ENV first). Check each environment:
  `bin/rails runner 'p Rails.application.credentials.secret_key_base == Rails.application.secret_key_base'`.
  If `false`, set `config.secret_key = Rails.application.credentials.secret_key_base` in `config/initializers/devise.rb`,
  otherwise outstanding reset/invite tokens break.
- Optional: `:unprocessable_entity` → `:unprocessable_content` (`devise.rb:305`). Removes the `routes.rb:103` deprecation warnings.
- devise_invitable: go to **2.0.14** now (supports Devise 5). 3.x moves invitations to a `devise_invitations` table
  (irreversible data migration, needs `create_resource_on_invitation: true` in `user.rb`, N+1 fix in
  `employees/_employee.html.erb:58`, cache-touch on invite) — schedule as its own PR.
- No view changes needed (all Devise views are overridden). Visible change: failed-login flash text.

### 5.3 Pay 11.4 → 12.5 and Stripe 18 → 21 (after §3.3)
- Bump both together: each Pay minor pins one Stripe major (Pay 12.5 ⇒ `stripe ~> 21`; mismatch aborts boot).
- `purchase/checkouts_controller.rb:11`: `payment_method_types: ["card"]` is rejected by the Stripe API version stripe-ruby 20+ pins → use `allowed_payment_method_types: ["card"]` (or remove to use Dashboard settings).
- Pay 12 wraps Stripe errors in `Pay::Stripe::Error` — rescue `Pay::Error` if adding error handling.
- Recommended: `client_reference_id: Pay::Stripe.to_client_reference_id(current_user)`; call
  `Pay::Stripe.sync_checkout_session(params[:session_id])` on the success page so the billing page updates without waiting for the webhook.
- Stripe Dashboard: create a new webhook endpoint (`/pay/webhooks/stripe`) on API version **2026-10-28.endive**, snapshot events,
  including `invoice.updated`, `payment_method.automatically_updated`, `charge.updated`; rotate via an array `signing_secret`, then retire the old endpoint. Test mode first.
- Optional post-deploy resync: `Pay::Stripe::Subscription.find_each(&:sync!)`.

### 5.4 Low-risk bumps (one PR, no or trivial code change)
| Gem | From → To | Notes |
|---|---|---|
| rails | 8.1.1 → **8.1.4.1** | ~25 security advisories (ActionPack, ActionView, ActiveStorage). Do first. |
| solid_queue | 1.2.4 → 1.7.2 | `bin/rails solid_queue:update` (batches migration, required in 2.0) |
| solid_cable | 3.0 → 4.1 | `Gemfile` `~> 4.1`; optional `solid_cable:update` (drops channel index) |
| puma | 6.6 → 8.1 | `config/puma.rb` compatible; bind `0.0.0.0` explicitly if the health check is IPv4-only |
| image_processing | 1.x → 2.2 | **add `gem "mini_magick", "~> 5.4"`** (now optional); do after Rails 8.1.4 |
| newrelic_rpm | 9.x → 10.9 | ActiveJob metric names change — update dashboards/alerts |
| wicked_pdf | git master → `~> 2.8` | released 2.8.2 has Ruby 3.4 + Propshaft fixes |
| wkhtmltopdf-binary | 0.12.6.7 → 0.12.6.10 | |
| tailwindcss-rails, importmap-rails, turbo-rails, propshaft, bootsnap, aws-sdk-s3, nokogiri, pg, debug, web-console | patch/minor | no code change expected |
| importmap JS pins | trix 2.1.8 → 2.1.19, @rails/request.js 0.0.11 → 0.0.13, slim-select 2.9 (4.x is a major — separate) | `bin/importmap outdated` |
| **remove** pg_search, vcr, webmock | unused (no references in `app/`, `lib/`, `test/`); vcr 6.3 breaks on Ruby 4 | |

---

## 6. Phase 3 — Ruby 3.4.7 → 4.0.9
Do after Rails 8.1.4.1 (it fixes Ruby 4 delegator warnings).
- Bump `Gemfile:7`, `.ruby-version`, `mise.toml`, CI; `bundle update --bundler` (lockfile says 2.4.10; Ruby 4 ships Bundler 4).
- Native gems must move to versions with Ruby 4 builds: nokogiri ≥ 1.19.0, pg ≥ 1.6.3, ffi ≥ 1.17.3.
- `tzinfo-data` platforms → `%i[windows jruby]` (Bundler 4 deprecates mingw names).
- mocha ≥ 3.1 (uses removed `CGI.parse`); vcr removed in §5.4.
- All app files parse on Ruby 4.0; no use of removed APIs found. Riskiest at runtime: stimulus_reflex/cable_ready, virtus (via rails-patterns), wicked_pdf — exercise reflexes, PDF reports and image variants by hand.

---

## 7. Phase 4 — Later / strategic
- `config.load_defaults 8.1` (from 8.0) via `bin/rails app:update` + `new_framework_defaults_8_1.rb`, flipping one at a time.
- acts_as_tenant 1.0 → 2.2 (behaviour changes for cross-tenant validation and ActiveJob tenant resolution; 24 tenant models — needs its own test pass).
- Replace `rails-patterns` (only `Patterns::Service`, 41 classes; drags in abandoned virtus) with a 15-line `ApplicationService`.
- StimulusReflex is in low maintenance — plan a move to Turbo Streams / morphing.
- wkhtmltopdf is abandoned upstream — plan a move (e.g. Grover/Ferrum or Prawn).
- devise_invitable 3.x, slim-select 4, Tailwind/UI polish.

---

## 8. CI and tooling
- `.github/workflows/rubyonrails.yml`: `ruby/setup-ruby` v1.152.0 → current (needed for Ruby 4), `actions/checkout@v3` → current, Postgres 15 → 16,
  run system tests (add Chrome), `bin/rails solid_queue:check`, brakeman, bundler-audit; trigger on PRs to `upgrade` too.
- `renovate.json`: `config:base` → `config:recommended`; group Rails, Pay+Stripe, Devise family.
- Local dev: `docker compose up -d` (Postgres 16 on port 5433), `bin/rails dev:cache`, `bin/setup`. Write this into README.

## 9. Suggested sequencing and parallel workstreams

```
Phase 0  ┬─ A: JS imports + StimulusReflex pin (3.1, 3.2)        ─┐
         ├─ B: Pay schema + billing fixes (3.3)                    │
         ├─ C: Solid Queue/Cable + database.yml + deploy (3.4, 3.5)├─> re-run full suite ─> Phase 1 (merge dev)
         └─ D: small fixes + secrets rotation (3.6)               ─┘
Phase 2  ┬─ E: Rails 8.1.4.1 + low-risk bumps (5.4)  ─> then image_processing
         ├─ F: Pagy 43 (5.1)
         ├─ G: Devise 5 + pwned (5.2)
         └─ H: Pay 12.5 + Stripe 21 (5.3, needs B)
Phase 3  ── Ruby 4.0.9 (needs E)
Phase 4  ── load_defaults 8.1, acts_as_tenant 2, rails-patterns, StimulusReflex/wkhtmltopdf replacements
```
A–D touch disjoint files and can run in parallel; E–H likewise except H depends on B, and Ruby 4 depends on E.

## 10. Test checklist per phase
- **Every PR:** `bin/rails test`, `bin/rails test test/system`, brakeman, bundle-audit, browser console has no errors.
- **Billing:** trial sign-up creates a fake-processor subscription; checkout redirects to Stripe (card only); success page; billing portal; `stripe listen --forward-to localhost:3000/pay/webhooks/stripe` + `stripe trigger` for `checkout.session.completed`, `customer.subscription.updated/deleted`; renew/manage/expired states.
- **Auth:** sign-up (incl. pwned password), confirm, sign-in/out, timeout, password reset with a pre-deploy token, invite + accept (incl. pre-deploy invite), reflexes authenticate.
- **Pagination:** each listed controller shows the intended page size; infinite scroll loads page 2; `?page=999`/`?page=abc` return 200.
- **Jobs:** `bin/rails solid_queue:check`; worker stays up; recurring jobs enqueue; `deliver_later` mails arrive.
- **Ruby 4:** reflex actions, PDF export (KPIs, survey reports), avatar variants.

## 11. Open questions / not verified
- Production/staging: actual `pay_*` columns, whether a hand-made `database.yml` with queue/cable exists, `SECRET_KEY_BASE` vs credentials, Redis add-ons still attached.
- Hosting: Ruby 4.0.9 availability, ImageMagick installed, Puma IPv6 bind vs health checks, DigitalOcean Spaces checksum settings.
- Current Stripe webhook endpoint API version and event list.
- Whether the removed features (nuggets, knowledge base) and their data can be dropped.

---

## 12. Execution status (branch `claude/upgrade-phases-6f2b15`, 2026-11-19)

Test numbers: baseline on `upgrade-base` — unit 120/0/0, system 855 runs / 24 F / 12 E. Latest full system run
(`fdefdb42`, Ruby 4.0.9 + load_defaults 8.1): 855 runs / 1 F / 0 E; unit now 157/0/0. bundle-audit: 158 advisories → **0**.
brakeman: 13 mass-assignment warnings, unchanged.

| Item | Status |
|---|---|
| §3.1 JS imports, §3.2 SR pin | done on `upgrade-base`; §3.2 test sanity check ignored in test (`6c07691b`) |
| §3.3 Pay 7/8/10 migrations, billing fixes, SignUp error reporting | done (`d47b34d7`) |
| §3.4 Solid Queue recurring/queue config | done (`3d8deb51`) |
| §3.5 staging queue/cable, render-build, Procfile | done (`62efc76b`); queue/cable must be separate DBs (see README) |
| §3.6 small bugs | done: New Relic ENV key, letter_opener_web, bin/dev, dead code, favicon, Pagy `limit:`, SubscriptionManager, invitation text link, sign-up HTML fallback |
| Extra Phase 0 fixes | modal stacking (Tailwind 4), 27 duplicate test class names, Chrome 159 test-browser fixes, stale fixtures, racy tests |
| §4 merge `dev` | done (`f1bcaf87`): /up, Puma WEB_CONCURRENCY, prod force_ssl/static/STDOUT logs; nuggets/kbs drop migrations untouched |
| §5.4 Rails 8.1.4.1 + low-risk bumps | done; pg_search/vcr/webmock removed; importmap trix 2.1.19, request.js 0.0.13 |
| §5.1 Pagy 43.8 | done (`cf85de7f`) with pagination tests |
| §5.2 Devise 5, pwned, devise_invitable 2.0.14 | done (`1fd3503a`); Devise key pinned to Devise 4 order |
| §5.3 Pay 12.5 / Stripe 21 | done (`93d7c6e0`); optional client_reference_id/sync not changed |
| §6 Ruby 4.0.9 | done (`360295c9`, `69b15585`) |
| §7 load_defaults 8.1 | done (`d8b71729`) |
| §7 acts_as_tenant 2.2 | done (`34ec9cbf`); cross-tenant create is now a validation error (no app path does it) |
| §7 rails-patterns → ApplicationService | done (`b48bf019`) |
| §7 devise_invitable 3.x | **deferred**: 3.x never signs in a user who existed before the invite (this app creates employees, then invites), so after accepting they would land on the sign-in page instead of being signed in. Keeping 2.x behaviour means overriding a deliberate security change: product decision. A verified data migration (old tokens keep working), N+1 fix and tests are saved in the shared notes folder `devise_invitable3-attempt/`. |
| §7 StimulusReflex → Turbo Streams | **not done** (usage limit). Designed: HTTP shim keeping `data-reflex` markup, allow-listed `ReflexActionsController`, `morph` → Turbo Stream replace/update with morphing, page morph via `Turbo.morphBodyElements`. 37 actions in 21 reflexes. |
| §7 wkhtmltopdf replacement | **not done**; PDF smoke test exists (`test/controllers/report/kpis_pdf_test.rb`). Grover needs Node, Ferrum needs Chrome on the host, Prawn changes the PDF look: needs a decision. |
| §8 CI, renovate | done (`92d76544`, `89c9c470`, `ca50f063`) |

Remaining failing system test: `EmployeeSpacesPermissionsTest#test_space_participant_can_not_delete_a_thread` (intermittent).
It contradicts `Space::MessagePolicy#destroy?` (any participant may delete a thread since 2023) and only passed while two
`SpacesTest` classes shared a setup. Product must decide whether the policy or the test is right.

## 13. Human actions

- **Rotate the New Relic license key** (it is in git history); set `NEW_RELIC_LICENSE_KEY` everywhere. newrelic_rpm 10 renames ActiveJob metrics: update dashboards/alerts.
- Before deploying the Pay migrations: `bin/rails runner 'p Pay::Customer.column_names'` on production/staging; take a DB backup.
- Provision separate Solid Queue and Solid Cable databases; set `QUEUE_DATABASE_URL` and `CABLE_DATABASE_URL` (a shared fresh DB does not work with `db:prepare`). Remove Redis add-ons and `REDIS_URL`; run the worker as `bin/jobs start`.
- Check `SECRET_KEY_BASE` vs credentials: Devise is pinned to credentials first, so links stay valid, but confirm that credentials exist in each environment.
- Stripe Dashboard: new webhook endpoint `/pay/webhooks/stripe` on the API version stripe-ruby 21 pins (events incl. `invoice.updated`, `payment_method.automatically_updated`, `charge.updated`), test mode first; then exercise checkout, billing portal and webhooks with `stripe listen`.
- Hosting: Ruby 4.0.9 available, ImageMagick installed (avatar variants were not exercised locally), health check on `/up` with `force_ssl` (consider `ssl_options` redirect exclude for `/up`).
- Product sign-off: dropping nuggets/knowledge base (irreversible migrations), devise_invitable 3 sign-in change, the space-thread delete policy.
- Follow-up security fix: `ProjectsController#index` interpolates `params[:column]`/`params[:direction]` into `order` (SQL injection; brakeman does not flag it). Reflexes perform no authorization checks.
