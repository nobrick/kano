class Admin::Finance::Withdrawals::TransferController < Admin::ApplicationController
  helper_method :dashboard
  before_action :set_withdrawal, only: [:update]
  before_action :set_authorizer, only: [:update]

  def index
    q_params = dashboard.filter_params(params)
    @search = Withdrawal.audited.requested.ransack(q_params)
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
    @search = Withdrawal.audited.requested.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
    render 'index'
  end

  def update
    if transfer?
      do_transfer
    elsif decline?
      do_decline
    end
    redirect_to admin_finance_withdrawal_transfer_index_path
  end

  private

  def do_transfer
    if @withdrawal.transfer && @withdrawal.save
      flash[:success] = "确认转账成功"
    else
      flash[:alert] = @withdrawal.errors.full_messages
    end
  end

  def do_decline
    @withdrawal.assign_attributes(reason_params)
    if @withdrawal.decline && @withdrawal.save
      flash[:success] = "确认转账失败"
    else
      flash[:alert] = @withdrawal.errors.full_messages
    end
  end

  def set_authorizer
    @withdrawal.authorizer = current_user
  end

  def transfer?
    params[:go] == "transfer"
  end

  def decline?
    params[:go] == "decline"
  end

  def reason_params
    params.require(:withdrawal).permit(:reason_message)
  end

  def set_withdrawal
    @withdrawal = Withdrawal.find params[:id]
  end

  def dashboard
    @dashboard ||= ::Withdrawal::TransferDashboard.new
  end
end
