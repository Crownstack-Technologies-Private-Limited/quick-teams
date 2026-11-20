# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "trix-editor-overrides"
pin "reflex_actions"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"

# Hotwire
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Rails
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.13/src/index.js"

# Trix editor
pin "trix", to: "https://ga.jspm.io/npm:trix@2.1.19/dist/trix.esm.min.js"


# Slim Select
pin "slim-select", to: "https://cdn.jsdelivr.net/npm/slim-select@2.9.2/dist/slimselect.es.js"

# Stimulus plugins
pin "stimulus-scroll-to", to: "https://ga.jspm.io/npm:stimulus-scroll-to@4.1.0/dist/stimulus-scroll-to.mjs"
