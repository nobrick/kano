class Handymen::WithdrawalsController < ApplicationController
  before_action :authenticate_completed_handyman
  before_action :set_account

  # GET /withdrawals
  def index
    @withdrawals = @account.withdrawals
      .order(created_at: :desc)
      .page(params[:page])
      .per(7)

    @withdrawal = @account.withdrawals.build
    @withdrawal.validate
  end

  # GET /withdrawals/new
  def new
    @withdrawal = @account.withdrawals.build
  end

  # POST /withdrawals
  def create
    @withdrawal = current_handyman.withdrawals.build(withdrawal_params)
    if @withdrawal.request && @withdrawal.save
      redirect_to handyman_withdrawals_url, notice: t('.requested')
    else
      render :new
    end
  end

  private

  def withdrawal_params
    params.require(:withdrawal).permit(:bank_code, :account_no)
  end

  def set_account
    @account = current_handyman
  end
end
