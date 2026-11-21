# A job card can be read and changed by anyone who may view its owner's planner (UserPolicy#view_planner?).
class JobCardPolicy < ApplicationPolicy
  def show?
    planner_visible?
  end

  def create?
    planner_visible?
  end

  def update?
    planner_visible?
  end

  def destroy?
    planner_visible?
  end

  private

  def planner_visible?
    record.user.present? && record.user.account_id == user.account_id && UserPolicy.new(user, record.user).view_planner?
  end
end
