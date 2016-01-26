require 'rails_helper'
require 'support/payment'

RSpec.describe Order::HandymanBonusAgent do
  describe '#set_handyman_bonus' do
    let(:order) { create :contracted_order, handyman: handyman }
    let(:handyman) { create :handyman }

    context 'On :normal strategy' do
      # The number is 80 in production by default.
      let(:number) { 3 }
      let(:set_handyman_bonus) { -> {
        Order::HandymanBonusAgent
          .set_handyman_bonus(order, nil, number_for_extra_bonus: number)
      } }

      context 'When completes over NUMBER orders paid online in month' do
        before { create_paid_orders_for handyman, number }

        it 'sets handyman_bonus_total to 10' do
          expect(handyman.orders_paid_by_pingpp.completed_in_month.count)
            .to eq number
          set_handyman_bonus.call
          expect(order.handyman_bonus_total).to eq 10
        end
      end

      context 'When completes less than NUMBER orders paid online in month' do
        before do
          create_paid_orders_for handyman, number - 1
          create_cash_orders_for handyman, 1
        end

        it 'sets handyman_bonus_total to 5' do
          orders = handyman.orders.completed_in_month
          expect(orders.paid_by_pingpp.count).to eq number - 1
          expect(orders.paid_in_cash.count).to eq 1
          set_handyman_bonus.call
          expect(order.handyman_bonus_total).to eq 5
        end
      end
    end
  end
end
