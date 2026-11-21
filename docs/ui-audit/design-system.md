# Quick Teams design system

Source of truth in code: [`app/assets/tailwind/application.css`](../../app/assets/tailwind/application.css) (Tailwind 4 `@theme`
tokens + `@layer components`). The same tokens, styles and components live in Figma:
**[Quick Teams — UI audit & redesign](https://www.figma.com/design/Wlql3NPDHuO3c4MNPqSVE3)**

| Figma page | What is on it |
|---|---|
| 1 · Current UI (before) | Every captured page per user type (desktop), key mobile screens, annotated problems |
| 2 · Design system | Variables (Primitives, Color, Spacing & radius), text styles, elevation styles, components |
| 3 · Redesign (target & after) | Target screens built from the components, then before/after pairs of the implemented UI |

## Principles

1. **No functional change.** Every id, `data-*` attribute, form field name, turbo-frame id, route, and the text the system
   tests look for stays as it was. The redesign is classes, wrappers and CSS only.
2. **Re-map the palette, don't rewrite the markup.** The views use ~1,500 Tailwind colour utilities (`text-gray-500`,
   `bg-indigo-600`, `focus:ring-indigo-500`, `bg-primary-700`, `text-blue-600`…). `@theme` redefines those names:
   `gray-*` becomes a cool slate neutral and `indigo-*`, `blue-*`, `primary-*` all resolve to one brand scale. Existing
   utilities therefore land on the new system and stay consistent.
3. **Light theme only, on purpose.** The old `.form-text-field` carried `dark:` variants, so on a dark-mode OS every input
   turned slate-700 inside an otherwise white page. Dark mode is not offered; inputs are always light.
4. **Components are CSS classes** (Rails partials, no component library), so the same class names work in ERB,
   helpers (`ButtonHelper`, `TailwindFormBuilder`) and Stimulus-rendered HTML.

## Tokens

### Colour

| Role | Token (CSS) | Value | Use |
|---|---|---|---|
| Canvas | `--qt-bg-canvas` → `gray-50` | `#f8fafc` | table heads, side panels, auth background (signed-in pages sit on white: most views place unboxed content directly on the page, so a grey canvas would leave white/grey patches) |
| Surface | `--qt-bg-surface` → `white` | `#ffffff` | `body`, page header bands, cards, app bar, tables, inputs |
| Subtle | `--qt-bg-subtle` → `gray-100` | `#f1f5f9` | table heads, search field, hover |
| Brand | `--qt-bg-brand` → `primary-600` | `#4f46e5` | primary buttons, active tab underline, logo mark |
| Brand hover | `primary-700` | `#4338ca` | hover, brand text (7.0:1 on white) |
| Brand subtle | `primary-50` | `#eef2ff` | active nav item, selected menu item, current page |
| Text primary | `gray-900` | `#0f172a` | headings, body (17.9:1) |
| Text secondary | `gray-600` | `#475569` | supporting copy (7.6:1) |
| Text muted | `gray-500` | `#64748b` | meta, dates, table heads (4.8:1 — AA) |
| Icon / placeholder | `gray-400` | `#7b879b` | icons, placeholders (3.6:1 — AA for UI graphics; was 2.5:1) |
| Border | `gray-200` | `#e2e8f0` | dividers, cards; also the global default border colour (Tailwind 4 defaults to `currentColor`) |
| Border strong | `gray-300` | `#cbd5e1` | inputs, secondary buttons |
| Focus ring | `primary-500` | `#6366f1` | 2px outline/ring, 2px offset |
| Success / warning / danger | `green-*`, `amber-*`, `red-*` | Tailwind defaults | badges, flash, destructive buttons |

### Type — Inter (Google Fonts, system fallback)

| Style | Size / line | Weight | Class |
|---|---|---|---|
| Page title | 24 / 32 | 600, −0.4 tracking | `.page-title` (`text-2xl font-semibold tracking-tight`) |
| Section heading | 18 / 28 | 600 | `text-lg font-semibold` |
| Card title | 16 / 24 | 600 | `.card-title` |
| Body | 14 / 20 | 400 | `text-sm` |
| Body medium / label | 14 / 20 | 500 | `.form-label`, nav, buttons |
| Small / meta | 12 / 16 | 400 | `text-xs` |
| Overline | 12 / 16 | 600, +0.4 tracking, uppercase | `.table-head` |

### Spacing, radius, elevation

- Spacing: Tailwind's 4px scale (`--spacing: 0.25rem`). Page gutters 16 / 24 / 32px (`px-4 sm:px-6 lg:px-8`), card padding 20px,
  section gap 24px.
- Radius: `--radius-xs` 4px (focus outlines), `--radius-sm` 6px, `--radius-md` 8px (buttons, inputs, menus), `--radius-lg` 12px (cards, modals), full (badges, avatars).
- Shadows: `shadow-xs` (buttons, inputs), `shadow-sm` (auth card), `shadow-lg` (toasts), `shadow-lg` (dropdowns), `shadow-xl` (modals) — slate-tinted, low opacity.

## Components

| Component | Classes | Notes |
|---|---|---|
| App bar | `.app-bar`, `.brand-mark`, `.brand-name`, `.nav-selected`, `.nav-unselected` | White, sticky, 56px. Keeps `#menubar`, `#user-menu`, `#search`, `data-controller="dropdown"` and `nav-search`. |
| Mobile navigation | `<details>` + `.mobile-nav-link` | Below `sm` the links collapse into a native `<details>` menu (no JavaScript); hidden at desktop widths so tests and desktop users never see duplicates. |
| Page header | `.page-header`, `.page-title`, `.page-subtitle` | Title + count + primary action on one row, wraps on mobile. |
| Buttons | `.btn-primary`, `.btn-secondary`, `.btn-red` (danger), `.btn-ghost`, `.btn-sm`, `.icon-btn`, `.btn-inline-edit`, `.btn-inline-delete` | All `inline-flex`, 8px radius, visible focus ring. Icon-only buttons get `aria-label`. |
| Form fields | `.form-label`, `.form-text-field`, `.form-help`, `.field_with_errors` | One height/border/focus treatment for inputs, textareas, selects, slim-select and Trix. |
| Card | `.card`, `.card-header`, `.card-title`, `.card-body` | Used for lists, tables, forms on the side, settings panels. |
| Badge | `.badge-gray`, `.badge-brand`, `.badge-green`, `.badge-amber`, `.badge-red` | Tags, statuses, survey types, counts. |
| Table | `.table`, `.table-head`, `.table-body`, `.table-cell` | Subtle head, row hover; on mobile the table scrolls inside itself instead of widening the page. |
| Tabs | `.tab-bar`, `.selected-tab`, `.unselected-tab` | One horizontally scrollable tab bar at every width (the old mobile `<select>` never navigated). |
| Side menu | `.selected`, `.unselected`, `.svg-icon` | Account, settings and archive menus. |
| Dropdown | `.dropdown-panel`, `.dropdown-item` | `data-dropdown-target="menu"` markup unchanged. |
| Modal | `shared/_modal`, `_comment`, `_assessment` | Overlay `bg-gray-900/50` (the v3 `bg-opacity-75` no longer exists in Tailwind 4, so the overlay was solid grey), panel `rounded-xl shadow-xl`. |
| Flash / toast | `.toast-region`, `.flash-notice`, `.flash-alert`, `.toast-floating` | Floating toasts in a fixed top-centre region (they overlay the page, no layout shift). Still `p.notice` / `p.alert` (tests select them); notices fade after 6 s, alerts have a close button. In-form success confirmations (`devise/shared/_success_message`) float the same way; validation error lists stay inline next to their fields. |
| Empty state | `.empty-state` | `shared/_no_result_found` and "No record found." texts unchanged. |
| Pagination | classes on `shared/_paginator` only | Logic belongs to the Pagy upgrade; only CSS classes changed. |
| Trix | `trix-toolbar`, `trix-editor` in `actiontext.css` | Toolbar and editor match `.form-text-field`. |
| Slim Select | `slim.css` | Height, radius, border and brand colours match inputs. |

Untouched by design: `layouts/pdf.html.erb` and `survey/pdf/*` (PDF output), mailer layouts.

## Accessibility checklist applied

- Text contrast ≥ 4.5:1 (body, meta, table heads); UI graphics ≥ 3:1 (icons, borders of inputs).
- Visible `:focus-visible` outline on links, buttons, summaries and menu items — unlayered CSS so `focus:outline-none` in old markup can't remove it.
- `aria-label` on icon-only controls (user menu, "more" menu, add-tag `+` buttons, mobile menu toggle), `aria-current="page"` on the active nav item.
- `aria-label` on the nav search field (a `<label>` element would also match the `fill_in ""` locator some system tests use), real `<label for>` on the auth forms, no broken logo images.
- Respects the user's text size (rem-based), no content hidden behind hover only.
