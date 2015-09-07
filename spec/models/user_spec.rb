require 'rails_helper'

RSpec.describe Handyman, type: :model do
  let(:user) { create :user }

  it 'creates a user' do
    expect(user).to be_a User
    expect(user.handyman?).to eq false
  end
end
