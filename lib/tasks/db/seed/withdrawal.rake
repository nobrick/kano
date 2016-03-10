namespace :db do
  namespace :seed do
    desc "Load the seed data for admin withdrawal"
    task withdrawal: :environment do
      handymans = Handyman.all
      admin = Account.where(admin: true).first

      user = User.last

      handymans.each do |h|
        order = Order.new(
          handyman: h,
          address: user.primary_address,
          user: user,
          taxon_code: 'electronic/lighting',
          content: 'content',
          arrives_at:  31.days.ago,
          contracted_at: 31.days.ago,
          completed_at: 31.days.ago,
          user_total: 300.0,
          user_promo_total: 0.00,
          payment_total: 300,
          handyman_bonus_total: 5,
          handyman_total: 305,
          state: 'completed',
          created_at: 31.days.ago
        )

        order.save!(validate: false)

        payment = Payment.new(
          order: order,
          payment_method: 'wechat',
          expires_at: 5.hours.since,
          state: 'completed',
          created_at: 31.days.ago
        )

        payment.save!(validate: false)

        unfrozen_record = BalanceRecord.new(
          owner: h,
          balance: 305,
          prev_balance: 0,
          cash_total: 0,
          prev_cash_total: 0,
          adjustment: 305,
          adjustment_event: payment,
          in_cash: false,
          online_income_total: 305,
          prev_online_income_total: 0,
          bonus_sum_total: 5,
          prev_bonus_sum_total: 0,
          withdrawal_total: 0,
          prev_withdrawal_total: 0,
          created_at: 31.days.ago
        )

        unfrozen_record.save!(validate: false)

        adjustment = Random.new.rand(100)
        w = Withdrawal.new(
          unfrozen_record: unfrozen_record,
          handyman: h,
          bank_code: 'icbc',
          account_no: '6212261901000001503',
          total: adjustment,
          state: "requested"
        )
        w.save!(validate: false)
      end
    end
  end
end
