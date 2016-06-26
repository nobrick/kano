require Rails.root.join('lib/seed_helper')

namespace :db do
  namespace :seed do
    desc 'Load the seed data for records'
    task :records do |t, args|
      Rails.application.eager_load!
      SeedHelper.eager_load!
      date_last_month = Time.now.last_month
      date_llm = Time.now - 2.months

      SeedHelper.run do
        handyman = SeedHelper.create :handyman

        Timecop.travel(date_llm.change(day: 1)) do
          SeedHelper.create_paid_orders_for handyman, 2
        end

        Timecop.travel(date_llm.change(day: 28)) do
          SeedHelper.create_paid_orders_for handyman, 2
        end

        Timecop.travel(date_last_month.change(day: 7)) do
          withdrawal = Withdrawal.new(SeedHelper.attributes_for :withdrawal)
          withdrawal.handyman = handyman
          withdrawal.request && withdrawal.save!
        end
      end
      puts "users: #{User.count}"
      puts "handymen: #{Handyman.count}"
      puts "orders: #{Order.count}"
      puts "payments: #{Payment.count}"
      puts "withdrawals: #{Withdrawal.count}"
      puts "records: #{BalanceRecord.count}"
    end
  end
end
