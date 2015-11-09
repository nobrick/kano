namespace :admin do
  desc 'Set user as admin'
  task :set, [ :email ] => [ :environment ] do |t, args|
    user = User.find_by(email: args.email)
    raise 'User not found' if user.nil?
    if user.update_attribute(:admin, true)
      puts "Updated user #{user.name} successfully."
    else
      puts 'Update failed.'
    end
  end
end
