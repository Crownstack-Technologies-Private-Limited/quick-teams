require "test_helper"
require "fugit"

# Solid Queue refuses to start (and runs no jobs at all) if any recurring task is invalid.
class RecurringScheduleTest < ActiveSupport::TestCase
  tasks = ActiveSupport::ConfigurationFile.parse(Rails.root.join("config/recurring.yml"))

  tasks.each do |key, task|
    test "#{key} has a valid schedule and an existing job class or command" do
      assert Fugit.parse(task["schedule"], multi: :fail), "unparseable schedule #{task['schedule'].inspect}"
      if task["class"]
        assert task["class"].safe_constantize, "#{task['class']} does not exist"
        assert task["class"].constantize < ActiveJob::Base
      else
        assert task["command"].present?
      end
    end
  end

  test "schedules the archived-projects cleanup" do
    assert_includes tasks.values.map { |t| t["class"] }, "DeleteArchivedProjectsJob"
  end
end
