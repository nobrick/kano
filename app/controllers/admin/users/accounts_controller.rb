class Admin::Users::AccountsController < Admin::AccountsController

  helper_method :dashboard
  rescue_from ActiveRecord::StatementInvalid do
    redirect_to admin_user_accounts_path, flash: { alert: i18n_t('statement_invalid', 'RC') }
  end

  private

  def dashboard
    @dashboard = ::UserDashboard.new
  end
end
