# JSON endpoints behind the daily/weekly planner (daily_planner_controller.js, weekly_planner_controller.js).
# Job cards belong to a user; whoever may view that user's planner may read and change its cards.
class JobCardsController < BaseController
  before_action :set_job_card, only: [:show, :update, :destroy]

  def create
    @job_card = JobCard.new(job_card_params.merge(user: planner_owner))
    authorize @job_card

    if @job_card.save(context: :planner)
      render json: {
        id: @job_card.id,
        title: @job_card.title,
        slot_length: @job_card.slot_length,
        message: "Job card created successfully"
      }, status: :created
    else
      render json: { errors: @job_card.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    @job_card.assign_attributes(job_card_params)

    if @job_card.save(context: :planner)
      render json: {
        id: @job_card.id,
        message: "Job card updated successfully"
      }, status: :ok
    else
      render json: { errors: @job_card.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show
    render json: @job_card
  end

  def destroy
    @job_card.destroy
    render json: { message: "Job card deleted successfully" }, status: :ok
  end

  private

  def set_job_card
    @job_card = JobCard.joins(:user).merge(User.for_current_account).find(params[:id])
    authorize @job_card
  end

  def job_card_params
    params.require(:job_card).permit(:title, :description, :date, :session, :slot_start, :slot_length, :color)
  end

  def planner_owner
    User.for_current_account.find(params.require(:job_card)[:user_id])
  end

  # Errors are JSON for the planner's fetch calls, not the HTML redirects of ApplicationController.
  def user_not_authorized
    message = if @job_card&.persisted? && !@job_card.editable?
      "Job cards on past days can't be changed"
    else
      "You are not allowed to change this planner"
    end
    render json: { errors: [message] }, status: :forbidden
  end

  def record_not_found
    render json: { errors: ["Job card not found"] }, status: :not_found
  end
end
