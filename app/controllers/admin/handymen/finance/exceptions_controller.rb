class Admin::Handymen::Finance::ExceptionsController < Admin::ApplicationController
  helper_method :dashboard

  def index
    @handyman = Handyman.find params[:handyman_id]
    @failed_withdrawals = @handyman.withdrawals.failed.page(params[:page]).per(10)
  end

  private

  def dashboard
    @dashboard ||= Handyman::WithdrawalExecptionDashboard.new
  end
end
