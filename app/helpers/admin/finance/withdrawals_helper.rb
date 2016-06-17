module Admin::Finance::WithdrawalsHelper
  def admin_finance_withdrawal_render_tabs
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
    admin_render_tabs(tabs_info)
  end
end
