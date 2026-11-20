# Runs the `data-reflex` actions declared in views (see ApplicationReflex and reflex_actions.js).
# Replaces StimulusReflex's ActionCable channel with a plain POST answered by Turbo Streams.
class ReflexActionsController < BaseController
  # Every reflex action a view may trigger (reflex name => actions). Anything else is a 404.
  ACTIONS = {
    "AccountNotification" => %w[toggle_email_notification],
    "Attempt" => %w[answer score],
    "EmployeeFeedback" => %w[publish unpublish],
    "EmployeeKpi" => %w[assessment self_assessment team_assessment view_comment],
    "EmployeeNotification" => %w[toggle_email_notification],
    "EmployeeSkills" => %w[add remove select],
    "EmployeeStatus" => %w[change remove],
    "EmployeeTags" => %w[change remove],
    "EmployeeTimesheetsStats" => %w[last_week last_month since_beginning],
    "InviteEmployee" => %w[invite],
    "ProjectObservers" => %w[add add_project],
    "ProjectSkills" => %w[add remove],
    "ProjectStatus" => %w[change remove],
    "ProjectTags" => %w[change remove],
    "ProjectTimesheetsStats" => %w[last_week last_month since_beginning],
    "ReportSubmit" => %w[submit],
    "SurveyParticipantStats" => %w[summary],
    "SurveyStats" => %w[summary],
    "TicketStatus" => %w[change],
    "Todo" => %w[toggle_project_todo toggle_todo toggle_employee_todo],
  }.freeze

  REFLEX_CLASSES = Hash.new { |hash, name| hash[name] = "#{name}Reflex".constantize if ACTIONS.key?(name) }

  def create
    # The reflexes have never had policy checks of their own (BaseController still requires a signed-in
    # user of this account); see "Human actions" in docs/upgrade-plan.md.
    skip_authorization

    reflex_class, action = resolve(params[:reflex].to_s.delete_suffix("Reflex"), params[:reflex_action].to_s)
    return head :not_found unless reflex_class

    reflex = reflex_class.new(self, dataset_params)
    reflex.public_send(action)

    if reflex.streams.any?
      render turbo_stream: reflex.streams
    else
      head :no_content # the browser re-renders the page with morphing
    end
  end

  private

  # Returns the reflex class and action from the allow-list (never from the request), or nil.
  def resolve(name, action)
    allowed_name = ACTIONS.keys.find { |key| key == name }
    allowed_action = allowed_name && ACTIONS[allowed_name].find { |candidate| candidate == action }
    [REFLEX_CLASSES[allowed_name], allowed_action] if allowed_action
  end

  # Partials rendered by a reflex use relative names (render "skills") that resolve against the view
  # path of the page the element is on, as with StimulusReflex. Put that page's controller path first.
  def _prefixes
    @page_prefixes ||= [page_controller_path, *super].compact.uniq
  end

  def page_controller_path
    path = URI.parse(params[:page_path].to_s).path.sub(%r{\A/\d+(?=/|\z)}, "") # strip the /:account prefix
    Rails.application.routes.recognize_path(path.presence || "/")[:controller]
  rescue ActionController::RoutingError, URI::InvalidURIError
    nil
  end

  def dataset_params
    dataset = params[:dataset]
    dataset.respond_to?(:to_unsafe_h) ? dataset.to_unsafe_h : {}
  end
end
