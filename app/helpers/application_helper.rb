module ApplicationHelper
  def render_flash_message
    render 'shared/flash_messages' if render_flash?
  end

  def phone_link_for(account, *args)
    if account.phone.present?
      link_to account.readable_phone_number, "tel:#{account.phone}", *args
    else
      nil
    end
  end

  def display_nav_button?
    account_signed_in? || !wechat_request?
  end
end
