RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller

  # %w(current_user user_signed_in?).each do |method|
  #   define_method method do |*args|
  #     @controller.send method, *args
  #   end
  # end
end
