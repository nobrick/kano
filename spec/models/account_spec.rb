require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:account) { create :account, email: 'john@email.com' }

  it 'creates an account' do
    expect(account).to be_a Account
  end
end
