require "test_helper"

class PaginationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @account = @user.account
    ActsAsTenant.current_tenant = @account
    sign_in @user
  end

  def visit_path(path, **options)
    get "/#{@account.id}#{path}", **options, env: { "REQUEST_PATH" => "/#{@account.id}#{path}" }
  end

  def active_employees
    User.where(account: @account).active
  end

  def add_employees(count, active: true)
    count.times do |i|
      User.create!(first_name: "Zed#{i}", last_name: "Extra", email: "zed#{i}.#{active}@crownstack.com", password: "Sup3r-secret!",
                   account: @account, role: roles(:senior), job: jobs(:ios), discipline: disciplines(:engineering),
                   confirmed_at: Time.current, active: active, deactivated_on: (Time.current unless active))
    end
  end

  test "the team list shows 10 employees per page and links to the next page under the account path" do
    add_employees([11 - active_employees.count, 0].max)

    visit_path "/employees"

    assert_response :ok
    assert_select "tr[id^='user_']", 10
    assert_select "nav.pagination a[rel='next'][href=?]", "/#{@account.id}/employees?page=2"
    assert_select "nav.pagination a[rel='next'][aria-disabled]", 0
  end

  test "page 2 has the rest and a link back" do
    add_employees([11 - active_employees.count, 0].max)

    visit_path "/employees", params: { page: 2 }

    assert_response :ok
    assert_select "tr[id^='user_']", [active_employees.count - 10, 10].min
    assert_select "nav.pagination a[rel='prev']"
  end

  test "out-of-range and non-numeric pages render instead of raising" do
    visit_path "/employees", params: { page: 999 }
    assert_response :ok
    assert_select "tr[id^='user_']", 0

    visit_path "/employees", params: { page: "abc" }
    assert_response :ok
    assert_select "tr[id^='user_']", [active_employees.count, 10].min
  end

  test "lists paginated with LIMIT show 30 rows" do
    add_employees(31, active: false)

    visit_path "/archive/employees"

    assert_response :ok
    assert_select "tr[id^='user_']", 30
  end

  test "the infinite-scroll JSON for the schedule carries 20 entries and the next page link" do
    add_employees(21)

    visit_path "/schedule.json"

    assert_response :ok
    assert_equal 20, Nokogiri::HTML.fragment(response.parsed_body["entries"]).css("[id^='user_']").size
    assert_includes response.parsed_body["pagination"], %(rel="next")
    assert_includes response.parsed_body["pagination"], %(href="/#{@account.id}/schedule.json?page=2")
  end
end
