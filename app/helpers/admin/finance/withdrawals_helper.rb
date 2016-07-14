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
end
