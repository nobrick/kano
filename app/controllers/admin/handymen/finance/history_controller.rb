class Admin::Handymen::Finance::HistoryController < Admin::ApplicationController
  helper_method :dashboard

  def index
    @handyman = Handyman.find params[:handyman_id]
    q_params = dashboard.filter_params(params)
    @search = @handyman.balance_records.ransack(q_params)
    @unprocessed_withdrawals = @handyman.withdrawals.requested
    @balance_records = @search.result.includes(:adjustment_event).page(params[:page]).per(10)
  end

  private

  def dashboard
    @dashboard ||= Handyman::FinanceHistoryDashboard.new
  end
end
