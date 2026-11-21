# A job card can be read and changed by anyone who may view its owner's planner (UserPolicy#view_planner?).
# Cards on past days are read-only (JobCard#editable?, server date).
class JobCardPolicy < ApplicationPolicy
  def show?
    planner_visible?
  end

  def create?
    planner_visible?
  end

  def update?
    planner_visible? && record.editable?
  end

  def destroy?
    planner_visible? && record.editable?
  end

  private

  def planner_visible?
    record.user.present? && record.user.account_id == user.account_id && UserPolicy.new(user, record.user).view_planner?
  end
end
