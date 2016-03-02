namespace :db do
  desc 'Initialize handyman last_balance_record'
  task :init_account_last_balance_record do
    Handyman.find_each do |h|
      records = h.balance_records
      if records.present? && h.last_balance_record.nil?
        h.update_column(:last_balance_record_id, records.first.id)
      end
    end
  end
end
