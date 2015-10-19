require 'rails_helper'

RSpec.describe Users::CheckoutsController, type: :controller do
  before { sign_in :user, user }
  let(:user) { create :user }

  describe 'POST #create' do
    let(:order) { create :contracted_order, handyman: handyman, user: user }
    let(:handyman) { create :handyman }

    context 'by cash payment' do
      it 'completes the order' do
        expect(order.contracted?).to eq true
        post :create, id: order.id, order: { user_total: 200 }, p_method: :cash
        order.reload
        expect(order.user_total).to eq 200
        expect(order.completed?).to eq true
      end
    end
  end
end
