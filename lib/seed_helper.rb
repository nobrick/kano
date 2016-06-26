$:.unshift Rails.root.join('spec').to_s
require 'rspec'
require 'support/payment/test_helpers'
require 'support/timecop/test_helpers'
require 'admin/accounts_controller'

module SeedHelper
  extend ActiveSupport::Autoload
  extend Payment::TestHelpers
  extend FactoryGirl::Syntax::Methods
  extend RSpec::Mocks::ExampleMethods

  def self.run
    Rails.application.eager_load!
    spec = RSpec.describe do
      it do
        begin
          yield
        rescue => e
          puts e.inspect
          puts e.backtrace
          raise
        end
      end
    end
    spec.run
  end
end
