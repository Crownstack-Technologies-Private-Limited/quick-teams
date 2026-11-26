require "test_helper"
require "view_component/test_case"

# Shared base for component tests: renders with Rails URL helpers and a stubbed request path.
class UiComponentTestCase < ViewComponent::TestCase
  private

  def html(&block)
    Nokogiri::HTML.fragment(rendered_content)
  end
end
