class Admin::Finance::Withdrawals::HistoryController < Admin::ApplicationController
  helper 'admin/orders/history'
  helper_method :dashboard

  def index
    q_params = dashboard.filter_params(params)
    @search = Withdrawal.processed.ransack(q_params)
    respond_to do |format|
      format.html do
        @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
      end
      format.xlsx do
        @withdrawals = @search.result.includes(:handyman)
        render xlsx: 'excel'
      end
    end
  end

  def search
    q_params = dashboard.search_params(params)
    @search = Withdrawal.processed.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
    render 'index'
  end

  private

  def dashboard
    @dashboard ||= ::Withdrawal::HistoryDashboard.new
  end
end
