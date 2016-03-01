class Admin::Users::AccountsController < Admin::AccountsController

  helper_method :dashboard

  private

  def dashboard
    @dashboard = ::UserDashboard.new
  end
end
