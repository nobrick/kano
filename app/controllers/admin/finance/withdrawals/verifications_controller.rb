class Admin::Finance::Withdrawals::VerificationsController < Admin::ApplicationController
  helper_method :dashboard

  def index
    q_params = dashboard.filter_params(params)
    @search = withdrawals.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
  end

  def search
    q_params = dashboard.search_params(params)
    @search = withdrawals.ransack(q_params)
    @withdrawals = @search.result.includes(:handyman).page(params[:page]).per(10)
    render 'index'
  end

  # params
  #  id: withdrawal id
  #  withdrawal:
  #     audit_state: 'unaudited' or 'audited' or 'abnormal'
  def update
    Withdrawal.serializable do
      set_withdrawal
      @withdrawal.assign_attributes(verify_params)
      if @withdrawal.save
        msg = mark_as_invalid_withdrawal? ? "已标记" : "已审核"
        flash[:success] = msg
      else
        flash[:alert] = @withdrawal.errors.full_messages
      end
    end
    redirect_to admin_finance_withdrawal_verifications_path
  end

  private

  def mark_as_invalid_withdrawal?
    verify_params[:audit_state] == 'abnormal'
  end

  def verify_params
    params.require(:withdrawal).permit(:audit_state)
  end

  def withdrawals
    Withdrawal.requested.unaudited
  end

  def set_withdrawal
    @withdrawal = Withdrawal.find params[:id]
  end

  def dashboard
    @dashboard ||= ::Withdrawal::VerificationDashboard.new
  end
end
