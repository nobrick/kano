module ApplicationHelper
  def render_flash_message
    render 'shared/flash_messages' if render_flash?
  end
end
