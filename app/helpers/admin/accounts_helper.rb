module Admin::AccountsHelper
  def render_admin_account_breadcrumb(account, last_text)
    tabs_info = [
      {
        text: "#{ account.full_or_nickname }主页(ID: #{ account.id })",
        path: send("admin_#{ account.type.underscore }_path", account)
      },
      last_text
    ]
    render_admin_breadcrumb(tabs_info)
  end

  def edit_primary_address?(account)
    account.handyman?
  end
end
