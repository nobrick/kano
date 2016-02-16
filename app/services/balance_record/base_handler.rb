class BalanceRecord::BaseHandler
  attr_reader :event, :record, :last_record

  def initialize(event)
    @event = event
  end

  def perform(record)
    record.adjustment_event = event
    record.owner = event.handyman
    @record = record
    @last_record = record.owner.reload.latest_balance_record
    set_previous_balance
    yield
    set_current_balance
  end

  private

  def set_previous_balance
    if last_record
      record.prev_balance = last_record.balance
      record.prev_cash_total = last_record.cash_total
      record.prev_withdrawal_total = last_record.withdrawal_total
      record.prev_online_income_total = last_record.online_income_total
      record.prev_bonus_sum_total = last_record.bonus_sum_total
    else
      record.prev_balance = 0.00
      record.prev_cash_total = 0.00
      record.prev_withdrawal_total = 0.00
      record.prev_online_income_total = 0.00
      record.prev_bonus_sum_total = 0.00
    end
  end

  def set_current_balance(payload = default_payload)
    record.assign_attributes(payload)
  end

  def default_payload
    t_adjustment = record.adjustment
    t_withdrawal = t_adjustment < 0 ? -t_adjustment : 0
    t_income = t_adjustment > 0 ? t_adjustment : 0
    {
      balance: record.prev_balance + t_adjustment,
      cash_total: record.prev_cash_total,
      withdrawal_total: record.prev_withdrawal_total + t_withdrawal,
      online_income_total: record.prev_online_income_total + t_income,
      bonus_sum_total: record.prev_bonus_sum_total
    }
  end
end
