class Admin::Handymen::AccountsController < Admin::AccountsController

  helper_method :dashboard, :tabs_info

  before_action :set_address, only: [:show]

  private

  def set_address
    address = @account.primary_address
    @account.build_primary_address(addressable: @account) if address.blank?
    @city_code = address.try(:city_code) || '430100'
    @district_code = address.try(:code)
  end

  def dashboard
    @dashboard ||= HandymanDashboard.new
  end

  def tabs_info
    [
      {
        text: "技能认证管理",
        path: admin_handyman_certifications_path
      },
      {
        text: "师傅信息管理",
        path: admin_handyman_accounts_path
      }
    ]
  end

end
