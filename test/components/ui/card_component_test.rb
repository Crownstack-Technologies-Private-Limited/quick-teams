require_relative "../ui_component_test_case"

class Ui::CardComponentTest < UiComponentTestCase
  test "renders header, body, and footer" do
    render_inline(Ui::CardComponent.new(title: "Details")) do |card|
      card.with_actions { "EDIT" }
      card.with_footer { "FOOT" }
      "BODY"
    end
    assert_selector ".card .card-header .card-title", text: "Details"
    assert_selector ".card-header", text: "EDIT"
    assert_selector ".card-body", text: "BODY"
    assert_text "FOOT"
  end

  test "unpadded card has no card-body" do
    render_inline(Ui::CardComponent.new(padded: false)) { "TABLE" }
    assert_no_selector ".card-body"
    assert_no_selector ".card-header"
  end
end
