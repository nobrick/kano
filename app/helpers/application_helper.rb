module ApplicationHelper
  def render_flash_message
    render 'shared/flash_messages' if render_flash?
  end

  def phone_link_for(account)
    link_to account.readable_phone_number, "tel:#{account.phone}"
  end
end
