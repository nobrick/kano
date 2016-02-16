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
        post :create, id: order.id,
          order: { user_total: 200 },
          p_method: :cash
        order.reload
        expect(order.completed?).to eq true
        expect(order.user_total).to eq 200
      end

      it 'creates balloc record when payment completes' do
        expect {
          post :create,
            id: order.id,
            order: { user_total: 200 },
            p_method: :cash
        }.to change(BalanceRecord, :count).by 1

        record = handyman.latest_balance_record
        expect(record.bonus_sum_total).to eq 0
        expect(record.adjustment).to eq 200
      end

      it 'rollbacks and does not affect next POST when fails' do
        expect(order.contracted?).to eq true
        post :create,
          id: order.id,
          order: { user_total: -5 },
          p_method: :cash
        order.reload
        expect(order.contracted?).to eq true

        post :create,
          id: order.id,
          order: { user_total: 100 },
          p_method: :cash
        order.reload
        expect(order.completed?).to eq true
        expect(order.user_total).to eq 100
      end

      it 'sets handyman bonus and user promo to 0' do
        post :create,
          id: order.id,
          order: { user_total: 200 },
          p_method: :cash
        order.reload
        expect(order.handyman_bonus_total).to eq 0
        expect(order.user_promo_total).to eq 0
      end
    end

    context 'By PingPP payment' do
    end
  end
end
