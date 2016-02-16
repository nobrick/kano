class BalanceRecord::WithdrawalHandler < BalanceRecord::BaseHandler
  def perform(record)
    super(record) do
      record.in_cash = false
      record.adjustment = -event.total
    end
  end
end
