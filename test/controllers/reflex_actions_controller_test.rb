require "test_helper"

class ReflexActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @account = @user.account
    ActsAsTenant.current_tenant = @account
    @project = projects(:one)
    sign_in @user
  end

  def perform_reflex(reflex, action, dataset, page_path: "/#{@account.id}/projects/#{@project.id}/schedules")
    path = "/#{@account.id}/reflex_actions"
    post path, params: { reflex: reflex, reflex_action: action, dataset: dataset, page_path: page_path }, as: :json,
               headers: { "Accept" => "text/vnd.turbo-stream.html" }, env: { "REQUEST_PATH" => path }
  end

  test "a selector morph answers with a morphing turbo stream and changes the record" do
    status = project_statuses(:progess)

    perform_reflex "ProjectStatus", "change", { "project-id" => @project.id, "status-id" => status.id }

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_equal status, @project.reload.status
    # project/_status has no #project-status root, so the target's contents are morphed
    assert_select "turbo-stream[action='update'][target='project-status'][method='morph']"
  end

  test "dashed and underscored dataset keys both reach the reflex" do
    perform_reflex "ProjectTags", "change", { "project_id" => @project.id, "tag-id" => project_tags(:uat).id }

    assert_response :ok
    assert_includes @project.reload.project_tags, project_tags(:uat)
  end

  test "an action without a morph asks the browser to re-render the page" do
    assert_changes -> { @account.reload.email_enabled } do
      perform_reflex "AccountNotificationReflex", "toggle_email_notification", { "id" => @account.id }
    end

    assert_response :no_content
  end

  test "relative partials resolve against the page's controller" do
    skill = skills(:ruby)
    perform_reflex "ProjectSkills", "add", { "project-id" => @project.id, "skill-id" => skill.id },
                   page_path: "/#{@account.id}/projects/#{@project.id}/skills"

    assert_response :ok
    assert_includes @project.reload.skills, skill
    assert_select "turbo-stream[target='skills']"
  end

  test "only allow-listed reflex actions run" do
    perform_reflex "Todo", "send_email", { "id" => 1 }
    assert_response :not_found

    perform_reflex "Kernel", "exit", {}
    assert_response :not_found
  end

  test "requires a signed-in user of the account" do
    sign_out @user
    perform_reflex "ProjectStatus", "remove", { "project-id" => @project.id }

    assert_not_equal 200, response.status
    assert_not_nil @project.reload.status
  end
end
