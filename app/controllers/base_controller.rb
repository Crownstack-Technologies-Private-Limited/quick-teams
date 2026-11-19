class BaseController < ApplicationController
  include Pagy::Method

  before_action :authenticate_user!
  before_action :authenticate_account!
  after_action :verify_authorized

  LIMIT = 30

  def authenticate_account!
    raise Pundit::NotAuthorizedError unless current_user.account == Current.account
  end

  # Offset pagination for relations. Arrays (built in Ruby by some reports) are kept on a single
  # page, as before. Out-of-range or non-numeric ?page= values render an empty/first page, not a 500.
  def pagy_nil_safe(_params, collection, **options)
    options[:limit] = [collection.size, 1].max if collection.is_a?(Array)
    pagy(:offset, collection, **options)
  end
end
