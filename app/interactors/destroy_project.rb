class DestroyProject < ApplicationService
  def initialize(project)
    @project = project
  end

  def call
    project.destroy!
    true
  rescue StandardError
    false
  end

  private

  attr_reader :project
end
