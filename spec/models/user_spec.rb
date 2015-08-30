require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create :user, email: 'john@email.com' }

  it 'creates a user' do
    expect(user).to be_a User
  end
end
