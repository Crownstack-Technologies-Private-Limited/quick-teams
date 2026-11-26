require "test_helper"

class Report::KpisPdfTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:super)
    @account = @user.account
    ActsAsTenant.current_tenant = @account
    @attempt = survey_attempts(:kpi)
    sign_in @user
  end

  test "the performance report renders as a PDF through wkhtmltopdf" do
    path = "/#{@account.id}/report/kpis/performance_report.pdf"
    get path, params: { survey_type: Survey::Survey.survey_types.fetch("kpi"), participant_id: @attempt.participant.id, from_date: Date.today - 1.day, to_date: Date.today + 1.day },
              env: { "REQUEST_PATH" => path }

    assert_response :ok
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF-"), "expected a PDF, got #{response.body[0, 40].inspect}"
  end
end
