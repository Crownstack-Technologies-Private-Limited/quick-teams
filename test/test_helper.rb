ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  #parallelize(workers: :number_of_processors)
  parallelize(workers: 1)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # Never call the Have I Been Pwned API from the test suite (slow and flaky); a test can override this.
  setup { Pwned::Password.any_instance.stubs(:fetch_pwned_count).returns(0) }

  include Devise::Test::IntegrationHelpers
  ActiveRecord::Migration.maintain_test_schema!
end
