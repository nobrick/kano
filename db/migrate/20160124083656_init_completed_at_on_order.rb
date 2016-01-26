class InitCompletedAtOnOrder < ActiveRecord::Migration
  def up
    Rake::Task['db:init_order_completed_at'].invoke
  end

  def down
  end
end
