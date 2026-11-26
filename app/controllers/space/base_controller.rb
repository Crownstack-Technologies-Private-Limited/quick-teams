class Space::BaseController < BaseController
  before_action :set_space
  after_action :verify_authorized

  def set_space
    @space ||= Space.find(params["space_id"])
  end
end
