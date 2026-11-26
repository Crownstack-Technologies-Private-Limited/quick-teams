class Ui::CardComponentPreview < ViewComponent::Preview
  def default
    render(Ui::CardComponent.new(title: "Details")) do |card|
      card.with_actions { render Ui::ButtonComponent.new("Edit", href: "#", variant: :secondary, size: :sm) }
      "Card body content."
    end
  end

  def with_footer
    render(Ui::CardComponent.new(title: "Billing")) do |card|
      card.with_footer { "Footer text" }
      "Body"
    end
  end

  def stat_cards
    render_with_template(template: "ui/card_component_preview/stat_cards")
  end
end
