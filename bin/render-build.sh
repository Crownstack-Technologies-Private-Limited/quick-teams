#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
# db:prepare migrates the primary database and loads db/queue_schema.rb / db/cable_schema.rb
# into the Solid Queue / Solid Cable databases when they are empty.
bin/rails db:prepare
