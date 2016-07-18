module Admin::Finance::WithdrawalsHelper
  def render_admin_finance_withdrawal_tabs
    tabs_info = [
      {
        text: "提现审核",
        path: admin_finance_withdrawal_verifications_path
      },
      {
        text: "待处理提现",
        path: admin_finance_withdrawal_transfer_index_path
      },
      {
        text: "已处理提现",
        path: admin_finance_withdrawal_history_index_path
      }
    ]
    render_admin_tabs(tabs_info)
  end

  def finance_detail_path(balance_record)
    if balance_record.adjustment_event_type == "Withdrawal"
      admin_finance_withdrawal_path(balance_record.adjustment_event)
    else
      admin_order_path(balance_record.adjustment_event.order)
    end
  end
end
