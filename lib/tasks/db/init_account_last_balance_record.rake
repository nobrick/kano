namespace :db do
  desc 'Initialize handyman last_balance_record'
  task :init_account_last_balance_record do
    Handyman.find_each do |h|
      if handyman.last_balance_record.nil? && handyman.balance_records.present?
        h.update_column(:last_balance_record, handyman.balance_records.first)
      end
    end
  end
end
