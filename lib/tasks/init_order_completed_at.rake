namespace :db do
  desc 'Initialize order completed_at attribute'
  task :init_order_completed_at do |t, args|
    Order.all.each do |o|
      if o.completed_at.nil? && o.completed_payment
        o.update_column(:completed_at, o.completed_payment.updated_at)
      end
    end
  end
end
