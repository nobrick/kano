require 'rails_helper'
require 'support/payment'
require 'support/timecop'

RSpec.describe Handymen::WithdrawalsController, type: :controller do
  before { sign_in :handyman, handyman }
  let(:handyman) { create :handyman_with_taxons }
  let(:valid_params) { { withdrawal: attributes_for(:withdrawal) } }
  let(:params) { valid_params }
  let(:date) { on(2, 28) }
  let(:unfrozen_date) { on(2, 14) }
  let(:frozen_date) { on(2, 15) }
  let(:next_date) { on(3, 7) }
  let(:errors_count) { 1 }

  describe 'GET #index' do
    it 'returns http success and renders :index' do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
      expect(response).to render_template :new
    end
  end

  describe 'GET #create' do
    context 'With valid condition' do
      before { pay on unfrozen_date }

      it 'redirects to handyman_withdrawals_url' do
        on(date) { post :create, params }
        expect(response).to redirect_to handyman_withdrawals_url
      end

      it 'creates a new withdrawal for current handyman' do
        on(date) do
          expect { post :create, params }
            .to change(Withdrawal, :count).by 1
          expect(Withdrawal.count).to eq 1
          expect(Withdrawal.first.handyman).to eq handyman
        end
      end

      it 'creates valid withdrawal assign' do
        on(date) { post :create, params }
        expect(assigns :withdrawal).to be_valid
      end
    end

    shared_examples_for 'Invalid withdrawal request' do
      it 're-renders :new' do
        on(date) { post :create, params }
        expect(response).to render_template :new
      end

      it 'creates no withdrawal' do
        on(date) do
          expect { post :create, params }
            .not_to change(Withdrawal, :count)
        end
      end

      it 'adds errors to the model' do
        on(date) { post :create, params }
        expect(assigns(:withdrawal).errors.keys).to eq error_keys
        expect(assigns(:withdrawal).errors.values.count).to eq errors_count
      end
    end

    context 'On forbidden requesting date' do
      before { pay on(2, 1) }
      let(:date) { on(2, 27) }
      let(:error_keys) { [ :base ] }
      it_behaves_like 'Invalid withdrawal request'
    end

    context 'With no unfrozen records exist' do
      before { pay on frozen_date }
      let(:error_keys) { [ :unfrozen_record ] }
      it_behaves_like 'Invalid withdrawal request'
    end

    context 'With no records exist at all' do
      let(:error_keys) { [ :unfrozen_record ] }
      it_behaves_like 'Invalid withdrawal request'
    end

    context 'When withdrawal request exists' do
      before do
        pay on(1, 1)
        pay on(1, 20)
        on(1, 21) do
          post :create, params
          expect(assigns(:withdrawal).reload).to be_valid
        end
      end

      let(:date) { on(1, 28) }
      let(:error_keys) { [ :base ] }
      it_behaves_like 'Invalid withdrawal request'
    end

    context 'When paid on unfrozen date' do
      before { pay on unfrozen_date }
      let(:params) { valid_params.deep_merge(invalid) }

      context 'On invalid bank_code' do
        let(:invalid) { { withdrawal: { bank_code: '' } } }
        let(:error_keys) { [ :bank_code ] }

        it_behaves_like 'Invalid withdrawal request'
      end

      context 'On invalid account_no' do
        let(:invalid) { { withdrawal: { account_no: '' } } }
        let(:error_keys) { [ :account_no ] }

        it_behaves_like 'Invalid withdrawal request'
      end
    end
  end

  def pay(date, orders_count = 1)
    on(date) { create_paid_orders_for handyman, orders_count}
  end
end
