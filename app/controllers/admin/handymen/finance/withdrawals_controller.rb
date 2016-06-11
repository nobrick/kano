class Admin::Handymen::Finance::WithdrawalsController < Admin::ApplicationController
  def index
    @handyman = Handyman.find params[:handyman_id]
    @requested_withdrawals = @handyman.withdrawals.unprocessed
  end

  def show
    @withdrawal = Withdrawal.find params[:id]
  end
end
