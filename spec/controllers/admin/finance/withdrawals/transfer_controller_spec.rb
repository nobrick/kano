require 'rails_helper'
require 'support/timecop'
require 'support/payment'

RSpec.describe Admin::Finance::Withdrawals::TransferController,
  type: :controller do

  before do
    sign_in :user, admin
    on(14.days.until date) do
      create_paid_orders_for handyman, 1
      create_paid_orders_for another_handyman, 1
    end
  end

  let(:admin) { create :admin }
  let(:withdrawal) { create :requested_withdrawal, handyman: handyman }
  let(:handyman) { create :handyman }
  let(:another_handyman) { create :handyman }
  let(:date) { Time.now.last_month.change(day: permitted_days.sample) }
  let(:permitted_days) { [ 7, 14, 21, 28 ] }
  let(:audited_withdrawal) do
    create :requested_withdrawal,
      handyman: another_handyman,
      audit_state: 'audited'
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to render_template 'index'
    end

    it 'includes only the audited withdrawal' do
      on(date) { [ withdrawal, audited_withdrawal ] }
      get :index
      expect(assigns :withdrawals).to eq [ audited_withdrawal ]
    end 
  end

  describe 'POST #update' do
    it 'transfers the withdrawal' do
      on(date) { expect(withdrawal).to be_requested }
      on(1.day.since date) do
        post :update, id: withdrawal.id, go: 'transfer'
        withdrawal.reload
        expect(withdrawal).to be_transferred
      end
    end

    it 'declines the withdrawal' do
      on(date) do
        expect(withdrawal).to be_requested
        post :update,
          id: withdrawal.id,
          go: 'decline',
          withdrawal: {
            reason_message: 'some reason'
          }
        withdrawal.reload
        expect(withdrawal).to be_declined
      end
    end
  end
end
