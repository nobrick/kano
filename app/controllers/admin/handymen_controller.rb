class Admin::HandymenController < Admin::AccountsController
  helper_method :dashboard, :tabs_info
  rescue_from ActiveRecord::StatementInvalid do
    redirect_to admin_handyman_index_path, flash: { alert: i18n_t('statement_invalid', 'RC') }
  end


  private

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
        path: admin_handyman_index_path
      }
    ]
  end
end
