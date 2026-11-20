# Thin wrappers over Ui::AvatarComponent, kept so existing views and decorators keep working.
module AvatarHelper
  def display_xsmall_avatar(resource)
    render Ui::AvatarComponent.new(resource, size: :xs)
  end

  def display_small_avatar(resource)
    render Ui::AvatarComponent.new(resource, size: :sm)
  end

  def display_medium_avatar(resource)
    render Ui::AvatarComponent.new(resource, size: :md)
  end

  def display_large_avatar(resource)
    render Ui::AvatarComponent.new(resource, size: :lg)
  end
end
