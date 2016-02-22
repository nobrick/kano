class Handymen::WithdrawalsController < ApplicationController
  attr_reader :account
  before_action :authenticate_completed_handyman
  before_action :set_account
  before_action :set_withdrwal_info, only: [ :index, :new ]

  # GET /withdrawals
  def index
    @withdrawals = account.withdrawals
      .order(created_at: :desc)
      .page(params[:page])
      .per(7)
    @last_withdrawal_total = @withdrawals.first.try(:total) || 0
    @acc_withdrawal_total = @latest_record.try(:withdrawal_total) || 0
    @already_requested = @withdrawals.any?(&:requested?)
  end

  # GET /withdrawals/new
  def new
    @withdrawal = account.withdrawals.build
  end

  # POST /withdrawals
  def create
    @withdrawal = current_handyman.withdrawals.build(withdrawal_params)
    if @withdrawal.request && @withdrawal.save
      redirect_to handyman_withdrawals_url, notice: t('.requested')
    else
      set_withdrwal_info
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

  def set_withdrwal_info
    @balance = account.balance
    @unfrozen_balance = account.unfrozen_balance
    @frozen_balance = @balance - @unfrozen_balance
    @latest_record = account.latest_balance_record
    @is_today_permitted = Withdrawal.at_permitted_requesting_date?
    @next_permitted_date = Withdrawal.next_permitted_requesting_date
  end
end
