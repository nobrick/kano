class Admin::HandymenController < Admin::AccountsController
  helper_method :dashboard
  rescue_from ActiveRecord::StatementInvalid do
    redirect_to admin_handyman_index_path, flash: { alert: i18n_t('statement_invalid', 'RC') }
  end


  private

  def dashboard
    @dashboard ||= HandymanDashboard.new
  end
end
