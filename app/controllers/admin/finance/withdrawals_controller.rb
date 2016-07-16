class Admin::Finance::WithdrawalsController < Admin::ApplicationController
  def show
    @withdrawal = Withdrawal.find params[:id]
    @unfrozen_record = @withdrawal.unfrozen_record
    @handyman = @withdrawal.handyman
  end
end
