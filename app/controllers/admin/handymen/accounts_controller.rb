class Admin::Handymen::AccountsController < Admin::AccountsController

  helper_method :dashboard, :tabs_info

  # params
  #   page: page num
  def index
    @handymen = Handyman.page(params[:page]).per(10)
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
