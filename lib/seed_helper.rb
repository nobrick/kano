$:.unshift Rails.root.join('spec').to_s
require 'rspec'
require 'support/payment/test_helpers'
require 'support/timecop/test_helpers'

module SeedHelper
  extend Payment::TestHelpers
  extend FactoryGirl::Syntax::Methods
  extend RSpec::Mocks::ExampleMethods

  def self.run
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
