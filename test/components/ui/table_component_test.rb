require_relative "../ui_component_test_case"

class Ui::TableComponentTest < UiComponentTestCase
  test "renders head cells from columns and the block as body" do
    render_inline(Ui::TableComponent.new(wrapper_class: "hidden sm:block", body_id: "rows")) do |table|
      table.with_column("Name")
      table.with_column(class: "text-right") { "Status" }
      "<tr><td class='table-cell'>Quickhands</td></tr>".html_safe
    end
    assert_selector "div.hidden table.table thead th.table-head", count: 2
    assert_selector "th.table-head.text-right", text: "Status"
    assert_selector "tbody#rows.table-body td", text: "Quickhands"
  end
end
