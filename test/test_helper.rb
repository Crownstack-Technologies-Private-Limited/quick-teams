ENV["RAILS_ENV"] ||= "test"
require "etc"

# macOS: libpq crashes (segfault in connect_start) when a forked parallel worker opens its database connection
# and GSSAPI encryption negotiation is on. The test database is local, so turn the negotiation off.
ENV["PGGSSENCMODE"] ||= "disable"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

class ActiveSupport::TestCase
  # Run tests in parallel: forked workers, each with its own database (<DB_NAME>_test-N) and its own
  # Active Storage directory. System tests are limited by the Chrome instance each worker starts, so the
  # default is min(cores, 8). Override with PARALLEL_WORKERS=n; PARALLEL_WORKERS=1 runs serially.
  parallelize(workers: ENV.fetch("PARALLEL_WORKERS") { [Etc.nprocessors, 8].min }.to_i)

  parallelize_setup do |worker|
    storage_root = Rails.root.join("tmp/storage-#{worker}")
    FileUtils.rm_rf(storage_root)
    ActiveStorage::Blob.service = ActiveStorage::Service::DiskService.new(root: storage_root.to_s)
  end

  parallelize_teardown do |worker|
    FileUtils.rm_rf(Rails.root.join("tmp/storage-#{worker}"))
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # Never call the Have I Been Pwned API from the test suite (slow and flaky); a test can override this.
  setup { Pwned::Password.any_instance.stubs(:fetch_pwned_count).returns(0) }

  include Devise::Test::IntegrationHelpers
  ActiveRecord::Migration.maintain_test_schema!
end
