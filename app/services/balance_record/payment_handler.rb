class BalanceRecord::PaymentHandler < BalanceRecord::BaseHandler
  def perform(record)
    super(record) do
      record.in_cash = event.in_cash?
      record.adjustment = event.handyman_total
    end
  end

  private

  def set_current_balance
    if event.in_cash?
      super(cash_payload)
    else
      super
      record.bonus_sum_total += event.handyman_bonus_total
    end
  end

  def cash_payload
    {
      balance: record.prev_balance,
      cash_total: record.prev_cash_total + record.adjustment,
      withdrawal_total: record.prev_withdrawal_total,
      online_income_total: record.prev_online_income_total,
      bonus_sum_total: record.prev_bonus_sum_total
    }
  end
end
