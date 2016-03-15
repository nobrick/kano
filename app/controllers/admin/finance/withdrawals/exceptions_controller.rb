class Admin::Finance::Withdrawals::ExceptionsController < Admin::ApplicationController
  helper_method :dashboard

  def index
    q_params = dashboard.filter_params(params)
    @search = Withdrawal.verified_failure.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
  end

  def search
    q_params = dashboard.search_params(params)
    @search = Withdrawal.verified_failure.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
    render 'index'
  end

  private

  def dashboard
    @dashboard ||= ::Withdrawal::ExceptionDashboard.new
  end
end
