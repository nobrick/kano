class Admin::Finance::Withdrawals::VerificationsController < Admin::ApplicationController
  helper_method :dashboard
  before_action :set_withdrawal, only: [:update]

  def index
    q_params = dashboard.filter_params(params)
    @search = Withdrawal.unaudited.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
  end

  def search
    q_params = dashboard.search_params(params)
    @search = Withdrawal.unaudited.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
    render 'index'
  end

  # params
  #  id: withdrawal id
  #  withdrawal:
  #     verify_passed: true or false
  def update
    @withdrawal.assign_attributes(verify_params)
    if @withdrawal.save
      msg = mark_as_invalid_withdrawal? ? "标记成功" : "审核成功"
      flash[:success] = msg
    else
      flash[:alert] = @withdrawal.errors.full_messages
    end
    redirect_to admin_finance_withdrawal_verifications_path
  end

  private

  def mark_as_invalid_withdrawal?
    verify_params[:verify_passed] == 'false'
  end

  def verify_params
    params.require(:withdrawal).permit(:verify_passed)
  end

  def set_withdrawal
    @withdrawal = Withdrawal.find params[:id]
  end

  def dashboard
    @dashboard ||= ::Withdrawal::VerificationDashboard.new
  end
end
