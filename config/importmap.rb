# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "trix-editor-overrides"
pin "reflex_actions"
pin_all_from "app/javascript/controllers", under: "controllers", preload: true
pin_all_from "app/javascript/channels", under: "channels"

# Hotwire
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Rails
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.13/src/index.js"

# Trix editor
pin "trix", to: "https://ga.jspm.io/npm:trix@2.1.19/dist/trix.esm.min.js"

# Vendored copies in app/javascript: slim-select 3.2.0 (styles in app/assets/stylesheets/slim.css)
# and stimulus-scroll-to 4.1.0.
pin "slim-select", to: "slim-select.js"
pin "stimulus-scroll-to", to: "stimulus-scroll-to.js"
