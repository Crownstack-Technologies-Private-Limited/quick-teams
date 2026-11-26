require_relative "ui_component_test_case"

# Every preview example must render (they are the living style guide at /rails/view_components).
class PreviewsTest < UiComponentTestCase
  ViewComponent::Preview.all.each do |preview|
    preview.examples.each do |example|
      test "#{preview.name}##{example} renders" do
        render_preview(example, from: preview)
        assert_not_empty rendered_content.strip
      end
    end
  end
end
