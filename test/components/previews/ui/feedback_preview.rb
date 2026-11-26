class Ui::FeedbackPreview < ViewComponent::Preview
  def flash_messages
    render_with_template(template: "ui/feedback_preview/flash_messages")
  end

  def empty_state
    render Ui::EmptyStateComponent.new(title: "No result found", message: "No project has been created yet.", icon: :search)
  end

  def section_heading
    render Ui::SectionHeadingComponent.new(title: "Add New Employee", subtitle: "Please add detail of new employee.")
  end
end
