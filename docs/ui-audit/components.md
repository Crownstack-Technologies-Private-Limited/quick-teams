# Quick Teams UI components

A library of 51 reusable [ViewComponent](https://viewcomponent.org) components in `app/components/ui/`. Every view in the
app is built from them. They wrap the design tokens and CSS classes from [design-system.md](design-system.md)
(`app/assets/tailwind/application.css`): there is no second styling system. Markup, ids, `data-*` attributes (including `data-reflex`),
turbo-frame ids and form field names are unchanged from the views they replaced.

- **Use one**: `<%= render Ui::ButtonComponent.new("New Project", href: new_project_path) %>`. Slots use blocks:
  `render Ui::PageHeaderComponent.new(title: "Projects") do |header| header.with_actions { ... } end`.
- **Previews** (development only): <http://localhost:3000/rails/view_components> (any dev port). Preview URLs drop the `_preview` suffix, e.g.
  `/rails/view_components/ui/button_component/variants` and `/rails/view_components/ui/layout/split_layout`.
  Source: `test/components/previews/ui/`. A test renders every preview (`test/components/previews_test.rb`).
- **Tests**: `test/components/ui/*_test.rb` (`bin/rails test test/components`).
- **Tailwind** scans `app/components` (`@source` in `application.css`). Colour names that components build at runtime
  (`text-#{color}-800`: tags, statuses, the colour picker) are safelisted there with `@source inline(...)`.
- **Gotcha**: `render Ui::X.new(...) { ... }` binds the braces to `.new`, not `render`. Use `do ... end` (or parentheses:
  `render(Ui::X.new(...)) { ... }`) when you pass content to a component.
- Existing helpers keep working and now call the components: `ButtonHelper` (`edit_button`, `delete_button`, `confirm_button`,
  `styled_*_button`) and `AvatarHelper` (`display_*_avatar`). The shared partials `shared/_form_header`, `_no_result_found`,
  `_modal`, `_comment`, `_assessment`, `_avatar`, the settings menus and `devise/shared/*` are thin wrappers over components.


## Components

Views = number of view templates that render the component directly; "via" lists the helpers and other components that render it too.


### Actions

| Component | Variants / API | Views | Also used by |
|---|---|---|---|
| `Ui::ButtonComponent` | Button or link-button. Wraps the .btn-* classes from app/assets/tailwind/application.css.<br>`render Ui::ButtonComponent.new("New Project", href: new_project_path)` | 76 (85 uses) | `back_button`, `button_helper`, `card`, `modal`, `page_header` |
| `Ui::SubmitButtonComponent` | Submit input for a form builder: same &lt;input type="submit"> (name="commit", data-disable-with) as `form.submit`, with the standard button classes.<br>`render Ui::SubmitButtonComponent.new(form, "Save")` | 97 (100 uses) | – |
| `Ui::SplitSubmitButtonComponent` | Submit button with an optional "and do X" menu next to it (comment forms). Each option is another submit input of the same form. Needs an ancestor with `data-controller="dropdown"` (the Stimulus dropdown).<br>`render Ui::SplitSubmitButtonComponent.new(form, "Comment") do \|button\|` | 2 (2 uses) | – |
| `Ui::ButtonGroupComponent` | Joined row of secondary buttons (segmented control). Rounding of the first and last button comes from CSS.<br>`render Ui::ButtonGroupComponent.new do \|group\|` | 3 (3 uses) | – |
| `Ui::BackButtonComponent` | "Back" secondary button (browser history by default).<br>`render Ui::BackButtonComponent.new` | 29 (30 uses) | `form_actions`, `form_page` |
| `Ui::TextLinkComponent` | Inline text link. tone: :brand (auth pages, "forgot password") :strong (names inside sentences) or :row (record names in table rows) or :plain (wraps larger blocks).<br>`render Ui::TextLinkComponent.new("Log in", new_user_session_path)` | 78 (153 uses) | – |
| `Ui::KebabMenuComponent` | "More actions" (⋯) menu: an icon-only trigger button and a dropdown panel with the block's links.<br>`render Ui::KebabMenuComponent.new(button_id: "comment-menu", label: "Comment actions") do` | 4 (4 uses) | – |
| `Ui::DropdownComponent` | Dropdown menu driven by the Stimulus `dropdown` controller (click toggles, click outside / Esc hides).<br>`render Ui::DropdownComponent.new(button_id: "menu-button", button_variant: :secondary) do \|dd\|` | 4 (6 uses) | `kebab_menu` |

### Page structure

| Component | Variants / API | Views | Also used by |
|---|---|---|---|
| `Ui::PageComponent` | Outermost wrapper of a full page body (inside the layout's &lt;main>).<br>`render Ui::PageComponent.new { render "employee/title", employee: @employee ... }` | 56 (56 uses) | – |
| `Ui::PageHeaderComponent` | Page title row: &lt;h1> + optional meta (count / position) on the left, actions on the right.<br>`render Ui::PageHeaderComponent.new(title: "Projects", subtitle: "(12 projects)") do \|header\|` | 24 (24 uses) | – |
| `Ui::SectionHeadingComponent` | Heading + supporting text for a form or section (title/subtitle block above a form).<br>`render Ui::SectionHeadingComponent.new(title: "Profile", subtitle: "Update your details")` | 3 (4 uses) | – |
| `Ui::SplitLayoutComponent` | The main page body of detail pages: a wide primary column (lists, tables) and a secondary column (forms, stats) that sits beside it on large screens and below it on small ones.<br>`render Ui::SplitLayoutComponent.new do \|layout\|` | 26 (26 uses) | – |
| `Ui::SettingsLayoutComponent` | Two-column settings page: side menu on the left, content on the right.<br>`render Ui::SettingsLayoutComponent.new(menu: :account) do` | 23 (23 uses) | – |
| `Ui::FormPageComponent` | Centered page for a single card form (account edit, invitations): title row, optional subtitle and actions.<br>`render Ui::FormPageComponent.new(title: "Edit User", subtitle: "Change your sign-in details.", max_width: "max-w-2xl") do \|page\|` | 3 (3 uses) | – |
| `Ui::FormContainerComponent` | Centered narrow column that holds a form page (heading, fields, buttons) with consistent spacing.<br>`render Ui::FormContainerComponent.new { ...form fields... }` | 67 (67 uses) | – |
| `Ui::LinkListComponent` | Titled list of links (the reports index: "Goals", "Schedules"...).<br>`render Ui::LinkListComponent.new(title: "Goals") do \|list\|` | 1 (7 uses) | – |
| `Ui::AuthPageComponent` | Signed-out page shell: gradient background, brand mark, title (+ optional subtitle), then the form.<br>`render Ui::AuthPageComponent.new(title: "Sign in to your account", heading_tag: :h1) do \|page\|` | 6 (6 uses) | – |
| `Ui::AuthCardComponent` | The white card holding an auth form, with validation errors above it. Render it inside `form_for` so the card's fields belong to the form.<br>`render Ui::AuthCardComponent.new(resource: resource, class: "mt-4") do` | 6 (6 uses) | – |
| `Ui::TabsComponent` | Horizontal tab bar of links; the current page is selected (aria-current="page").<br>`render Ui::TabsComponent.new(id: "ticket-tabs") do \|tabs\|` | 4 (4 uses) | – |
| `Ui::SideMenuComponent` | Vertical settings/account menu (aside). Items are links with an icon; the current page is highlighted.<br>`render Ui::SideMenuComponent.new(id: "menu") do \|menu\|` | 3 (3 uses) | – |
| `Ui::NavItemComponent` | Top-bar link (desktop) or mobile-menu link. Selected when it points at the current page.<br>`render Ui::NavItemComponent.new("Projects", projects_path)` | 4 (15 uses) | – |

### Data display

| Component | Variants / API | Views | Also used by |
|---|---|---|---|
| `Ui::TableComponent` | Data table: header row from `columns`, body rows from the block (usually a partial per row).<br>`render Ui::TableComponent.new(body_options: { id: "todos", data: { "infinite-scroll-target": "entries" } }) do \|table\|` | 54 (54 uses) | – |
| `Ui::ListRowComponent` | One row of a simple list (account settings: disciplines, roles, tags...). Wrap in the turbo-frame yourself.<br>`render Ui::ListRowComponent.new(title: role.name.titleize, subtitle: nil) do \|row\|` | 13 (13 uses) | – |
| `Ui::CardComponent` | Surface for lists, tables, settings panels. Wraps .card / .card-header / .card-title / .card-body.<br>`render Ui::CardComponent.new(title: "Details") do \|card\|` | 1 (1 uses) | – |
| `Ui::StatCardComponent` | Metric: small muted label, large value. `variant: :card` is a bordered tile; `:plain` sits inline in a grid.<br>`render Ui::StatCardComponent.new(label: "Billable", value: 12, hint: "of 20 resources")` | 3 (7 uses) | – |
| `Ui::StatStripComponent` | Row of centred headline numbers (report totals). Four across on medium screens, stacked on mobile.<br>`render Ui::StatStripComponent.new(columns: 4) do \|strip\|` | 3 (3 uses) | – |
| `Ui::BadgeComponent` | Status pill / tag / count. Wraps .badge-{color}.<br>`render Ui::BadgeComponent.new("Active", color: :green)` | 3 (3 uses) | – |
| `Ui::TagComponent` | Coloured chip for tags and statuses. Colours are Tailwind colour names stored on the record ("blue", "red").<br>`render Ui::TagComponent.new(tag.name, color: tag.color)                       # table cell` | 28 (36 uses) | – |
| `Ui::StatusDotComponent` | Small coloured dot for statuses (project status colour).<br>`render Ui::StatusDotComponent.new(color: project.status&.color \|\| "white")` | 7 (7 uses) | `list_row` |
| `Ui::AvatarComponent` | User avatar: uploaded image, or initials on a brand tint. Same markup the AvatarHelper always produced.<br>`render Ui::AvatarComponent.new(user, size: :sm)` | 0 (0 uses) | `avatar_group`, `avatar_helper`, `billable_avatar`, `timeline_item` |
| `Ui::AvatarGroupComponent` | Overlapping row of avatars with an optional "+N" overflow label.<br>`render Ui::AvatarGroupComponent.new(project.display_participants, size: :xs, overflow: project.display_additional_participants, title: names)` | 3 (3 uses) | – |
| `Ui::BillableAvatarComponent` | Medium avatar with a green (billable) / red (non billable) dot in the corner and a matching tooltip.<br>`render Ui::BillableAvatarComponent.new(employee)` | 2 (2 uses) | – |
| `Ui::TimelineItemComponent` | One entry of the activity feed: avatar on the connecting line, sentence (block content), timestamp on the right.<br>`render Ui::TimelineItemComponent.new(user: event.user, timestamp: display_created_at(event)) do` | 47 (47 uses) | – |
| `Ui::ProgressBarComponent` | Labelled score bar: green from 80%, yellow from 50%, red below.<br>`render Ui::ProgressBarComponent.new(title: "Communication", score: 7.5, scale: 10)` | 1 (1 uses) | – |
| `Ui::PaginationComponent` | Right-aligned pagination bar around the Pagy nav (shared/_paginator keeps the Pagy 43 logic).<br>`render Ui::PaginationComponent.new(@pagy)` | 46 (46 uses) | – |

### Forms

| Component | Variants / API | Views | Also used by |
|---|---|---|---|
| `Ui::FormFieldComponent` | Label + control + help/error text, for controls the form builder does not wrap (selects, checkboxes, custom controls). The control is the block content.<br>`render Ui::FormFieldComponent.new(label: "Discipline", for_id: "employee_discipline_id", help: "Optional") do` | 8 (16 uses) | – |
| `Ui::CheckboxFieldComponent` | Checkbox with its explanatory label on one row. The checkbox itself (from the form builder) is the block.<br>`render Ui::CheckboxFieldComponent.new(label: "Billable", for_id: "employee_billable") do` | 1 (2 uses) | – |
| `Ui::FormActionsComponent` | Row of form buttons aligned to the end (Back + Save).<br>`render Ui::FormActionsComponent.new do` | 41 (41 uses) | – |
| `Ui::ColorPickerComponent` | Radio group for choosing a tag colour; each option shows a coloured chip.<br>`render Ui::ColorPickerComponent.new(name: "people_tag[color]", selected: tag.color, id_prefix: "people_tag")` | 10 (10 uses) | – |
| `Ui::RadioGroupComponent` | Inline group of radio buttons with coloured labels (the "Nature of comment" choice).<br>`render Ui::RadioGroupComponent.new(name: "comment[status]", label: "Nature Of comment", selected: "stale",` | 4 (4 uses) | – |
| `Ui::SearchFieldComponent` | Search input with a live results panel, driven by the Stimulus `nav-search` controller (it fetches `url` as you type and fills the `results` list).<br>`render Ui::SearchFieldComponent.new(url: "/search/surveys", placeholder: "Search Survey")` | 7 (7 uses) | `search_result` |
| `Ui::SearchResultComponent` | One option in a live-search results list (rendered into the `results` target of Ui::SearchFieldComponent). With `href:` the option sits inside a link; reflex options pass `data:` / `id:`.<br>`render Ui::SearchResultComponent.new(href: employee_team_path(e)) { e.display_name }` | 9 (11 uses) | – |
| `Ui::SearchDividerComponent` | Labelled rule between groups of search results ("Projects", "Jobs").<br>`render Ui::SearchDividerComponent.new("Projects")` | 1 (2 uses) | – |
| `Ui::InlineErrorsComponent` | Validation messages shown above an inline edit row. Renders nothing for nil / empty.<br>`render Ui::InlineErrorsComponent.new(local_assigns[:messages])` | 12 (12 uses) | – |

### Feedback and overlays

| Component | Variants / API | Views | Also used by |
|---|---|---|---|
| `Ui::FlashComponent` | Flash message. Keeps `p.notice` / `p.alert` (system tests select them) and hides itself when empty.<br>`render Ui::FlashComponent.new(:notice, notice)` | 1 (2 uses) | – |
| `Ui::AlertComponent` | Inline message box: success confirmation or a list of validation errors.<br>`render Ui::AlertComponent.new(:success, message: "Saved", data: { controller: "auto-dismiss" })` | 2 (2 uses) | – |
| `Ui::EmptyStateComponent` | "Nothing here" block. Title + message, optional icon and action.<br>`render Ui::EmptyStateComponent.new(title: "No result found", message: "No project has been created yet.")` | 3 (3 uses) | – |
| `Ui::LoadingComponent` | Placeholder text shown inside a lazy turbo-frame until its content arrives.<br>`turbo_frame_tag "events", src: events_path, loading: :lazy do` | 5 (8 uses) | – |
| `Ui::TextComponent` | A paragraph with the app's text scale: size, tone and alignment instead of hand-written class strings.<br>`render Ui::TextComponent.new("No record found.", align: :right)` | 4 (7 uses) | – |
| `Ui::ModalComponent` | Modal dialog rendered into &lt;div id="modal"> (the Stimulus `modal` controller closes it).<br>`render Ui::ModalComponent.new(title: "Deactivate?", icon: :exclamation) do \|modal\|` | 5 (5 uses) | – |
| `Ui::IconComponent` | Inline SVG icon (Heroicons v1 paths already used across the app).<br>`render Ui::IconComponent.new(:search, class: "h-4 w-4 text-gray-400")` | 34 (60 uses) | `alert`, `button`, `dropdown`, `empty_state`, `kebab_menu`, `modal`, `search_field`, `side_menu`, `split_submit_button`, `tag` |

## Reference

### `Ui::ButtonComponent`

```ruby
# app/components/ui/button_component.rb
# Button or link-button. Wraps the .btn-* classes from app/assets/tailwind/application.css.
#
#   render Ui::ButtonComponent.new("New Project", href: new_project_path)
#   render Ui::ButtonComponent.new("Cancel", href: projects_path, variant: :secondary, size: :sm)
#   render Ui::ButtonComponent.new(href: edit_path, variant: :icon, "aria-label": "Edit") do
#     render Ui::IconComponent.new(:search)
#   end
#   render Ui::ButtonComponent.new("Delete", href: path, variant: :inline_delete, data: { ... })
#
# With `href:` it renders an <a> (through link_to, so data-turbo-method etc. work); otherwise a <button>.
```

### `Ui::SubmitButtonComponent`

```ruby
# app/components/ui/submit_button_component.rb
# Submit input for a form builder: same <input type="submit"> (name="commit", data-disable-with) as
# `form.submit`, with the standard button classes.
#
#   render Ui::SubmitButtonComponent.new(form, "Save")
#   render Ui::SubmitButtonComponent.new(form, "Save", class: "ml-2", id: "save")
```

### `Ui::SplitSubmitButtonComponent`

```ruby
# app/components/ui/split_submit_button_component.rb
# Submit button with an optional "and do X" menu next to it (comment forms). Each option is another submit
# input of the same form. Needs an ancestor with `data-controller="dropdown"` (the Stimulus dropdown).
#
#   render Ui::SplitSubmitButtonComponent.new(form, "Comment") do |button|
#     button.with_option("and mark closed")
#   end
```

### `Ui::ButtonGroupComponent`

```ruby
# app/components/ui/button_group_component.rb
# Joined row of secondary buttons (segmented control). Rounding of the first and last button comes from CSS.
#
#   render Ui::ButtonGroupComponent.new do |group|
#     group.with_button("Last Week", data: { reflex: "click->EmployeeTimesheetsStats#last_week", "reflex-dataset": "combined" })
#     group.with_button("Last Month", data: { reflex: "click->EmployeeTimesheetsStats#last_month", "reflex-dataset": "combined" })
#   end
```

### `Ui::BackButtonComponent`

```ruby
# app/components/ui/back_button_component.rb
# "Back" secondary button (browser history by default).
#
#   render Ui::BackButtonComponent.new
#   render Ui::BackButtonComponent.new(href: projects_path, class: "mr-2")
```

### `Ui::TextLinkComponent`

```ruby
# app/components/ui/text_link_component.rb
# Inline text link. tone: :brand (auth pages, "forgot password") :strong (names inside sentences) or :row (record names in table rows) or :plain (wraps larger blocks).
#
#   render Ui::TextLinkComponent.new("Log in", new_user_session_path)
#   render Ui::TextLinkComponent.new(user.display_name, employee_path(user), tone: :strong)
```

### `Ui::KebabMenuComponent`

```ruby
# app/components/ui/kebab_menu_component.rb
# "More actions" (⋯) menu: an icon-only trigger button and a dropdown panel with the block's links.
#
#   render Ui::KebabMenuComponent.new(button_id: "comment-menu", label: "Comment actions") do
#     link_to("Edit", edit_path, class: "dropdown-item", role: "menuitem")
#   end
#
# Wraps Ui::DropdownComponent (Stimulus `dropdown` controller); the label becomes the button's aria-label.
```

### `Ui::DropdownComponent`

```ruby
# app/components/ui/dropdown_component.rb
# Dropdown menu driven by the Stimulus `dropdown` controller (click toggles, click outside / Esc hides).
#
#   render Ui::DropdownComponent.new(button_id: "menu-button", button_variant: :secondary) do |dd|
#     dd.with_trigger { "Status" }
#     dd.with_item("Active", "#", data: { reflex: "click->EmployeeStatus#change" })
#   end
#
# Icon-only triggers must pass `label:` (becomes aria-label).
```

### `Ui::PageComponent`

```ruby
# app/components/ui/page_component.rb
# Outermost wrapper of a full page body (inside the layout's <main>).
#
#   render Ui::PageComponent.new { render "employee/title", employee: @employee ... }
#   render Ui::PageComponent.new(tag: :div)
```

### `Ui::PageHeaderComponent`

```ruby
# app/components/ui/page_header_component.rb
# Page title row: <h1> + optional meta (count / position) on the left, actions on the right.
#
#   render Ui::PageHeaderComponent.new(title: "Projects", subtitle: "(12 projects)") do |header|
#     header.with_actions { render Ui::ButtonComponent.new("New Project", href: new_project_path) }
#   end
#
# `bordered: false` drops the bottom border and white band (headers that sit inside a tab layout).
# The block's own content (not the actions slot) is rendered under the title row, e.g. a search field.
```

### `Ui::SectionHeadingComponent`

```ruby
# app/components/ui/section_heading_component.rb
# Heading + supporting text for a form or section (title/subtitle block above a form).
#
#   render Ui::SectionHeadingComponent.new(title: "Profile", subtitle: "Update your details")
#
# An optional block is rendered to the right of the heading (actions).
```

### `Ui::SplitLayoutComponent`

```ruby
# app/components/ui/split_layout_component.rb
# The main page body of detail pages: a wide primary column (lists, tables) and a secondary column
# (forms, stats) that sits beside it on large screens and below it on small ones.
#
#   render Ui::SplitLayoutComponent.new do |layout|
#     layout.with_primary(id: "todo-list", data: { controller: "infinite-scroll" }) { ... }
#     layout.with_secondary { ... }
#   end
#
# `inset: false` removes the side gutters (full-bleed tables). The secondary slot is optional.
```

### `Ui::SettingsLayoutComponent`

```ruby
# app/components/ui/settings_layout_component.rb
# Two-column settings page: side menu on the left, content on the right.
#
#   render Ui::SettingsLayoutComponent.new(menu: :account) do
#     ...content...
#   end
#
# menu: :account | :settings | :archive (the matching shared/*_menu partial)
# width: :narrow (6 of 12 columns, default) or :wide (8 of 12)
```

### `Ui::FormPageComponent`

```ruby
# app/components/ui/form_page_component.rb
# Centered page for a single card form (account edit, invitations): title row, optional subtitle and actions.
#
#   render Ui::FormPageComponent.new(title: "Edit User", subtitle: "Change your sign-in details.", max_width: "max-w-2xl") do |page|
#     page.with_actions { render Ui::BackButtonComponent.new }
#     form...
#   end
```

### `Ui::FormContainerComponent`

```ruby
# app/components/ui/form_container_component.rb
# Centered narrow column that holds a form page (heading, fields, buttons) with consistent spacing.
#
#   render Ui::FormContainerComponent.new { ...form fields... }
#   render Ui::FormContainerComponent.new(width: "max-w-2xl", class: "z-10")
```

### `Ui::LinkListComponent`

```ruby
# app/components/ui/link_list_component.rb
# Titled list of links (the reports index: "Goals", "Schedules"...).
#
#   render Ui::LinkListComponent.new(title: "Goals") do |list|
#     list.with_link("All Pending goals", goals_reports_path(status: 0))
#   end
```

### `Ui::AuthPageComponent`

```ruby
# app/components/ui/auth_page_component.rb
# Signed-out page shell: gradient background, brand mark, title (+ optional subtitle), then the form.
#
#   render Ui::AuthPageComponent.new(title: "Sign in to your account", heading_tag: :h1) do |page|
#     page.with_subtitle { "Or #{link_to ...}" }
#     render "form"
#   end
```

### `Ui::AuthCardComponent`

```ruby
# app/components/ui/auth_card_component.rb
# The white card holding an auth form, with validation errors above it.
# Render it inside `form_for` so the card's fields belong to the form.
#
#   render Ui::AuthCardComponent.new(resource: resource, class: "mt-4") do
#     ...fields...
#   end
```

### `Ui::TabsComponent`

```ruby
# app/components/ui/tabs_component.rb
# Horizontal tab bar of links; the current page is selected (aria-current="page").
#
#   render Ui::TabsComponent.new(id: "ticket-tabs") do |tabs|
#     tabs.with_tab("Open Tickets", ticket_open_path)
#     tabs.with_tab("Closed Tickets", ticket_closed_path)
#   end
#
# `id:` is the wrapper id that tests and turbo-frame targets rely on (e.g. "employee-tabs").
```

### `Ui::SideMenuComponent`

```ruby
# app/components/ui/side_menu_component.rb
# Vertical settings/account menu (aside). Items are links with an icon; the current page is highlighted.
#
#   render Ui::SideMenuComponent.new(id: "menu") do |menu|
#     menu.with_item("Account", detail_path, icon: :cog)
#   end
```

### `Ui::NavItemComponent`

```ruby
# app/components/ui/nav_item_component.rb
# Top-bar link (desktop) or mobile-menu link. Selected when it points at the current page.
#
#   render Ui::NavItemComponent.new("Projects", projects_path)
#   render Ui::NavItemComponent.new("Projects", projects_path, mobile: true)
```

### `Ui::TableComponent`

```ruby
# app/components/ui/table_component.rb
# Data table: header row from `columns`, body rows from the block (usually a partial per row).
#
#   render Ui::TableComponent.new(body_options: { id: "todos", data: { "infinite-scroll-target": "entries" } }) do |table|
#     table.with_column("Done")
#     table.with_column { sort_link(column: "name", label: "Project") }
#     render partial: "todo", collection: @todos
#   end
#
# `table_class:` adds classes to the <table> (e.g. "table-auto"); `body_options:` become attributes of <tbody>
# (id, data-infinite-scroll-target...). Body rows keep using the .table-cell class. Put the table inside a
# scrolling wrapper (`overflow-x-auto`) when it can be wider than the viewport.
```

### `Ui::ListRowComponent`

```ruby
# app/components/ui/list_row_component.rb
# One row of a simple list (account settings: disciplines, roles, tags...). Wrap in the turbo-frame yourself.
#
#   render Ui::ListRowComponent.new(title: role.name.titleize, subtitle: nil) do |row|
#     row.with_leading { render Ui::StatusDotComponent.new(color: tag.color) }
#     row.with_actions { edit_button(path) + delete_button(path) }
#   end
```

### `Ui::CardComponent`

```ruby
# app/components/ui/card_component.rb
# Surface for lists, tables, settings panels. Wraps .card / .card-header / .card-title / .card-body.
#
#   render Ui::CardComponent.new(title: "Details") do |card|
#     card.with_actions { render Ui::ButtonComponent.new("Edit", href: path, variant: :secondary, size: :sm) }
#     "body content"
#   end
#
# `padded: false` renders the content edge to edge (tables inside a card).
```

### `Ui::StatCardComponent`

```ruby
# app/components/ui/stat_card_component.rb
# Metric: small muted label, large value. `variant: :card` is a bordered tile; `:plain` sits inline in a grid.
#
#   render Ui::StatCardComponent.new(label: "Billable", value: 12, hint: "of 20 resources")
#   render Ui::StatCardComponent.new(label: "Total Hours", value: stats.total_hours, variant: :plain)
```

### `Ui::StatStripComponent`

```ruby
# app/components/ui/stat_strip_component.rb
# Row of centred headline numbers (report totals). Four across on medium screens, stacked on mobile.
#
#   render Ui::StatStripComponent.new(columns: 4) do |strip|
#     strip.with_stat("Logged Hours", stats.total_hours)
#   end
```

### `Ui::BadgeComponent`

```ruby
# app/components/ui/badge_component.rb
# Status pill / tag / count. Wraps .badge-{color}.
#
#   render Ui::BadgeComponent.new("Active", color: :green)
```

### `Ui::TagComponent`

```ruby
# app/components/ui/tag_component.rb
# Coloured chip for tags and statuses. Colours are Tailwind colour names stored on the record ("blue", "red").
#
#   render Ui::TagComponent.new(tag.name, color: tag.color)                       # table cell
#   render Ui::TagComponent.new(status.name, color: status.color, size: :md,
#     remove: { id: "remove", data: { reflex: "click->EmployeeStatus#remove", "employee-id": employee.id } })
#
# `remove:` adds a small "x" button (aria-label "Remove <label>") with those HTML options.
```

### `Ui::StatusDotComponent`

```ruby
# app/components/ui/status_dot_component.rb
# Small coloured dot for statuses (project status colour).
#
#   render Ui::StatusDotComponent.new(color: project.status&.color || "white")
```

### `Ui::AvatarComponent`

```ruby
# app/components/ui/avatar_component.rb
# User avatar: uploaded image, or initials on a brand tint. Same markup the AvatarHelper always produced.
#
#   render Ui::AvatarComponent.new(user, size: :sm)
#
# Sizes: :xs (28px) :sm (32px) :md (40px) :lg (160px).
```

### `Ui::AvatarGroupComponent`

```ruby
# app/components/ui/avatar_group_component.rb
# Overlapping row of avatars with an optional "+N" overflow label.
#
#   render Ui::AvatarGroupComponent.new(project.display_participants, size: :xs, overflow: project.display_additional_participants, title: names)
```

### `Ui::BillableAvatarComponent`

```ruby
# app/components/ui/billable_avatar_component.rb
# Medium avatar with a green (billable) / red (non billable) dot in the corner and a matching tooltip.
#
#   render Ui::BillableAvatarComponent.new(employee)
```

### `Ui::TimelineItemComponent`

```ruby
# app/components/ui/timeline_item_component.rb
# One entry of the activity feed: avatar on the connecting line, sentence (block content), timestamp on the right.
#
#   render Ui::TimelineItemComponent.new(user: event.user, timestamp: display_created_at(event)) do
#     "Ada added a goal ..."
#   end
```

### `Ui::ProgressBarComponent`

```ruby
# app/components/ui/progress_bar_component.rb
# Labelled score bar: green from 80%, yellow from 50%, red below.
#
#   render Ui::ProgressBarComponent.new(title: "Communication", score: 7.5, scale: 10)
```

### `Ui::PaginationComponent`

```ruby
# app/components/ui/pagination_component.rb
# Right-aligned pagination bar around the Pagy nav (shared/_paginator keeps the Pagy 43 logic).
#
#   render Ui::PaginationComponent.new(@pagy)
```

### `Ui::FormFieldComponent`

```ruby
# app/components/ui/form_field_component.rb
# Label + control + help/error text, for controls the form builder does not wrap
# (selects, checkboxes, custom controls). The control is the block content.
#
#   render Ui::FormFieldComponent.new(label: "Discipline", for_id: "employee_discipline_id", help: "Optional") do
#     form.collection_select(:discipline_id, ...)
#   end
```

### `Ui::CheckboxFieldComponent`

```ruby
# app/components/ui/checkbox_field_component.rb
# Checkbox with its explanatory label on one row. The checkbox itself (from the form builder) is the block.
#
#   render Ui::CheckboxFieldComponent.new(label: "Billable", for_id: "employee_billable") do
#     form.check_box(:billable, class: Ui::CheckboxFieldComponent::INPUT_CLASS)
#   end
```

### `Ui::FormActionsComponent`

```ruby
# app/components/ui/form_actions_component.rb
# Row of form buttons aligned to the end (Back + Save).
#
#   render Ui::FormActionsComponent.new do
#     safe_join([render(Ui::BackButtonComponent.new), form.submit("Save", class: "btn-primary ml-2")])
#   end
```

### `Ui::ColorPickerComponent`

```ruby
# app/components/ui/color_picker_component.rb
# Radio group for choosing a tag colour; each option shows a coloured chip.
#
#   render Ui::ColorPickerComponent.new(name: "people_tag[color]", selected: tag.color, id_prefix: "people_tag")
```

### `Ui::RadioGroupComponent`

```ruby
# app/components/ui/radio_group_component.rb
# Inline group of radio buttons with coloured labels (the "Nature of comment" choice).
#
#   render Ui::RadioGroupComponent.new(name: "comment[status]", label: "Nature Of comment", selected: "stale",
#     options: [["progress", "Progress", "green"], ["stale", "Stale", "yellow"], ["regress", "Regress", "red"]])
```

### `Ui::SearchFieldComponent`

```ruby
# app/components/ui/search_field_component.rb
# Search input with a live results panel, driven by the Stimulus `nav-search` controller
# (it fetches `url` as you type and fills the `results` list).
#
#   render Ui::SearchFieldComponent.new(url: "/search/surveys", placeholder: "Search Survey")
#   render Ui::SearchFieldComponent.new(url: "/search/users?project_id=1", id: "search-observers",
#            label: "Search to add new observer", icon: false)
#
# variant: :form (regular input, default) or :navbar (compact grey field for the app bar).
# `label:` renders a visible label; `sr_label:` a screen-reader-only one; otherwise `aria_label` names the input.
```

### `Ui::SearchResultComponent`

```ruby
# app/components/ui/search_result_component.rb
# One option in a live-search results list (rendered into the `results` target of Ui::SearchFieldComponent).
# With `href:` the option sits inside a link; reflex options pass `data:` / `id:`.
#
#   render Ui::SearchResultComponent.new(href: employee_team_path(e)) { e.display_name }
#   render Ui::SearchResultComponent.new(id: "add", data: { reflex: "click->EmployeeSkills#add", "skill-id": s.id }) { s.name }
```

### `Ui::SearchDividerComponent`

```ruby
# app/components/ui/search_divider_component.rb
# Labelled rule between groups of search results ("Projects", "Jobs").
#
#   render Ui::SearchDividerComponent.new("Projects")
```

### `Ui::InlineErrorsComponent`

```ruby
# app/components/ui/inline_errors_component.rb
# Validation messages shown above an inline edit row. Renders nothing for nil / empty.
#
#   render Ui::InlineErrorsComponent.new(local_assigns[:messages])
```

### `Ui::FlashComponent`

```ruby
# app/components/ui/flash_component.rb
# Flash message. Keeps `p.notice` / `p.alert` (system tests select them) and hides itself when empty.
#
#   render Ui::FlashComponent.new(:notice, notice)
#   render Ui::FlashComponent.new(:alert, alert)
```

### `Ui::AlertComponent`

```ruby
# app/components/ui/alert_component.rb
# Inline message box: success confirmation or a list of validation errors.
#
#   render Ui::AlertComponent.new(:success, message: "Saved", data: { controller: "auto-dismiss" })
#   render Ui::AlertComponent.new(:error, title: "2 errors prohibited this user from being saved:", items: user.errors.full_messages, id: "error_explanation")
```

### `Ui::EmptyStateComponent`

```ruby
# app/components/ui/empty_state_component.rb
# "Nothing here" block. Title + message, optional icon and action.
#
#   render Ui::EmptyStateComponent.new(title: "No result found", message: "No project has been created yet.")
#   render(Ui::EmptyStateComponent.new(title: "No tickets", icon: :ticket)) { link_button }
```

### `Ui::LoadingComponent`

```ruby
# app/components/ui/loading_component.rb
# Placeholder text shown inside a lazy turbo-frame until its content arrives.
#
#   turbo_frame_tag "events", src: events_path, loading: :lazy do
#     render Ui::LoadingComponent.new("Hold on a sec while I fetch events...")
#   end
```

### `Ui::TextComponent`

```ruby
# app/components/ui/text_component.rb
# A paragraph with the app's text scale: size, tone and alignment instead of hand-written class strings.
#
#   render Ui::TextComponent.new("No record found.", align: :right)
#   render Ui::TextComponent.new("Occupancy 80%", size: :xl, tone: :strong, align: :right, class: "px-8")
```

### `Ui::ModalComponent`

```ruby
# app/components/ui/modal_component.rb
# Modal dialog rendered into <div id="modal"> (the Stimulus `modal` controller closes it).
#
#   render Ui::ModalComponent.new(title: "Deactivate?", icon: :exclamation) do |modal|
#     modal.with_body { "Are you sure?" }
#     modal.with_footer do
#       render(Ui::ButtonComponent.new("Cancel", variant: :secondary, data: { action: "modal#close" }))
#     end
#   end
#
# `dismissible: false` is for blocking dialogs (expired subscription): no #modal wrapper, no Stimulus close.
#
# Without `title:` the block content is placed straight into the panel (forms, custom headers).
# The panel is `relative` on purpose: the backdrop is `fixed`, and Tailwind 4's `transform` no longer
# creates a stacking context, so an un-positioned panel is painted under the backdrop and its buttons
# become unclickable.
```

### `Ui::IconComponent`

```ruby
# app/components/ui/icon_component.rb
# Inline SVG icon (Heroicons v1 paths already used across the app).
#
#   render Ui::IconComponent.new(:search, class: "h-4 w-4 text-gray-400")
#
# Decorative by default (aria-hidden); pass `label:` to expose it to assistive tech.
```


## Pattern inventory

What was repeated across `app/views/**` (479 templates) before the library, and which component replaced it.
"Before" counts come from `grep` on the merged redesign branch; "now" is the number of component renders.

| Repeated pattern | Before | Component |
|---|---|---|
| `btn-primary` / `btn-secondary` / `btn-red` / `btn-inline-*` links and buttons | 133 + 73 + 5 + 15 in ~140 files | `ButtonComponent` (links, `<button>`), `ButtonHelper` |
| `form.submit ... class: "btn-..."` | 111 | `SubmitButtonComponent` |
| "Back" `javascript:history.back()` button | 29 | `BackButtonComponent` |
| Inline SVG icons (Heroicons pasted into views) | 109 `<svg>` in 37 files | `IconComponent` (38 icons), 0 left in views |
| Page title row (`h1` + count + action) | 32 | `PageHeaderComponent` (+ `SectionHeadingComponent` for form headings: 66 via `shared/_form_header`) |
| Page wrapper `relative z-0 flex-1 overflow-y-auto` | 62 | `PageComponent` |
| Two-column detail page body (`lg:col-span-2` + `xl:border-l`) | 32 | `SplitLayoutComponent` |
| Settings / account / archive page with side menu | 23 | `SettingsLayoutComponent`, `SideMenuComponent` (3 menus, 30 items) |
| Tab bars (project, employee, survey, tickets) | 4 partials, 100 links | `TabsComponent` |
| Top bar links (desktop + mobile) and "more" / profile menus | 14 + 3 menus | `NavItemComponent`, `DropdownComponent` |
| Tables with header row | 54 | `TableComponent` |
| Pagination wrapper around the Pagy nav | 46 | `PaginationComponent` |
| Status / tag chips (`bg-<color>-100 text-<color>-800`), with and without remove button | 40 | `TagComponent` (+ `StatusDotComponent`, `BadgeComponent`) |
| Avatars, avatar rows, billable dot | 84 files | `AvatarComponent`, `AvatarGroupComponent`, `BillableAvatarComponent` via `AvatarHelper` |
| Activity feed entries (home, employee and project timelines) | 47 | `TimelineItemComponent` |
| Narrow form page `main.max-w-lg ... space-y-4` | 66 | `FormContainerComponent` |
| Auth pages (sign in, sign up, password, confirmation, invitation) | 6 | `AuthPageComponent`, `AuthCardComponent`, `FormFieldComponent`, `TextLinkComponent` |
| Account list rows, inline edit errors, colour radio group | 13 + 12 + 10 | `ListRowComponent`, `InlineErrorsComponent`, `ColorPickerComponent` |
| Modals (`shared/_modal`, `_comment`, `_assessment`, expired / success billing dialogs) | 5 | `ModalComponent` |
| Flash messages, validation / success boxes | 2 + 2 | `FlashComponent`, `AlertComponent` |
| Empty and loading states | 5 + 5 | `EmptyStateComponent`, `LoadingComponent` |
| "More actions" kebab menus | 4 | `KebabMenuComponent` |
| Live search boxes (`nav-search` controller) | 5 | `SearchFieldComponent` |
| Report totals strip, timesheet stats, score bar | 3 + 2 + 1 | `StatStripComponent`, `StatCardComponent`, `ProgressBarComponent` |
| Cards (danger zone), form button rows, form fields | 1 + 41 + 14 | `CardComponent`, `FormActionsComponent`, `FormFieldComponent`, `CheckboxFieldComponent` |
| Report index link groups (`h3` + links) | 7 groups, 32 links | `LinkListComponent` |
| Nav search result options and dividers | 9 views, ~25 options | `SearchResultComponent`, `SearchDividerComponent` |
| Segmented Last week / Last month and assessment buttons | 3 pairs | `ButtonGroupComponent` |
| "Comment" submit with an "and mark ..." menu | 3 | `SplitSubmitButtonComponent` |
| "Nature of comment" radios | 4 | `RadioGroupComponent` |
| Checkbox / input class strings (`border-gray-300 ... focus:ring-indigo-500`) | 27 files | `.form-check`, `.form-text-field` classes, `FormFieldComponent` |
| Muted / strong paragraphs and notes | 9 | `TextComponent` |

## Intentional exceptions

Markup that is still hand-written, and why. Everything else in `app/views` renders components.

| Where | What | Why it stays |
|---|---|---|
| ~200 `td.table-cell` row cells in the row partials (`projects/_project`, `employees/_employee`, ...) | `<td class="table-cell ...">` | `table-cell` is the design-system class for a body cell. Rows are rendered through cached collection partials; a cell component would add an object per cell for no gain. |
| `tickets/show_buttons/_assignee`, `tickets/show_buttons/_user` | Status chip with a split menu whose colour comes from the ticket status | One-off, colour-coded control (reflex `li` options, dynamic `text-<color>-700` classes); no second use. |
| `project/todos/show`, `employee/todos/show`, `employee/feedbacks/show`, `project/reports/show`, `employee/reports/show` | Publish / complete toggles (`data-reflex`) coloured by state | State-coloured text buttons with reflex handlers; only these pages have them. `data-reflex` attributes untouched. |
| `survey/attempts/_score_question`, `survey/attempts/_option` | 1-10 score buttons and answer radios | Reflex-driven survey controls; the tests click these elements directly. |
| `message_comments/_new`, `report/timesheets/index` | A toggle button and a filter button | Single use inside a Stimulus toggle / report filter. |
| `user/notifications` | Notification preference form (checkboxes use `.form-check`) | Static settings form with one use of each control. |
| `employees/_employee` "Invite" | `<a data-reflex="click->InviteEmployee#invite">` without `href` | The system tests find it as an `a` element (`find("a", text: "Invite")`); `ButtonComponent` without `href` renders a `<button>`. |
| `account/billing/_renew`, `_manage`, `devise/registrations/edit` | `button_to` (a form with one button) | `button_to` is the Rails helper for method/CSRF forms; styled with the `btn-*` classes. |
| `user/forms/_avatar` | Avatar uploader (hidden file input over the image) | Single use; the inline `onchange` submit is JS behaviour. |
| `surveys/show` | Empty pagination placeholder `div[data-infinite-scroll-target=pagination]` | The infinite-scroll controller expects the target; there is no `pagy` on this page. |
| `active_storage/blobs/_blob` | ActionText attachment `<figure>` | Markup and class names are defined by Action Text / `actiontext.css`; only its links use `TextLinkComponent`. |
| `shared/_paginator` | Pagy 43 nav markup | Wrapped by `PaginationComponent`; the logic belongs to the Pagy upgrade. |
| Mailers, `layouts/pdf.html.erb`, `survey/pdf/*` | Email and PDF templates | Out of scope by design. |

Cleanups made in the same pass: removed `dark:` classes (the design system is light only), the dead `ring-opacity-*` / `bg-opacity-*`
utilities (Tailwind 4 does not generate them: the ring rendered solid black, the avatar overlay solid), an empty search-results panel
and an empty `<label>` in `survey/assignees/_form` (no `nav-search` controller above them), the duplicate results panel in
`employee/skills/_form`, and the sr-only "Page title" `h1` on detail pages.
