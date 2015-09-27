require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create :user }

  it 'creates a user' do
    expect(user).to be_a User
    expect(user.handyman?).to eq false
  end

  describe 'has_many orders' do
    let(:order_attrs) do
      {
        content: 'something needs to be fixed',
        arrives_at: 4.hours.since,
        taxon_code: 'general'
      }
    end

    it 'may build orders' do
      order = user.orders.build(order_attrs)
      expect(order).to be_a Order
      order.save!
      expect(order.user).to eq user
      expect(user.orders).to eq [ order ]
    end
  end
end
