require 'rails_helper'

RSpec.describe Users::ProfilesController, type: :controller do
  before { sign_in :user, user }
  let(:user) { create :user }
  let(:address_attrs) { { primary_address_attributes: attributes_for(:address) } }

  describe 'GET #profile/complete' do
    it 'returns http success' do
      get :complete
      expect(assigns(:account)).to be current_user
      expect(response).to have_http_status(:success)
      expect(response).to render_template :complete
    end
  end

  describe 'PUT #update' do
    let(:new_attrs) do
      {
        email: 'new_email@example.com',
        phone: '13100008888',
        name: 'FOO',
        nickname: 'BAR',
        primary_address_attributes: {
          code: '430105',
          content: 'NEW_ADDRESS_CONTENT'
        }
      }
    end

    context 'with valid params' do
      it 'updates the profile attributes' do
        put :update, { profile: new_attrs }
        user.reload
        %w{ email phone name nickname }.each do |key|
          expect(user.send key).to eq new_attrs[key.to_sym]
        end
      end

      it 'updates the profile primary address' do
        put :update, { profile: new_attrs }
        primary_address = user.reload.primary_address
        expect(primary_address.content).to eq 'NEW_ADDRESS_CONTENT'
        expect(user.addresses).to include primary_address
      end

      it 'turns the replaced primary addresses into backup addresses' do
        expected_addresses = []
        expected_addresses << user.primary_address
        user.update!(address_attrs)
        expected_addresses << user.primary_address
        expect(user.addresses).to match_array expected_addresses

        put :update, { profile: new_attrs }
        expected_addresses << user.reload.primary_address
        expect(user.primary_address.content).to eq 'NEW_ADDRESS_CONTENT'
        expect(user.addresses).to match_array expected_addresses
      end
    end

    context 'with invalid params' do
      let :invalids do
        [
          { phone: '1' },
          { email: '' },
          { primary_address_attributes: { content: '' } },
          { primary_address_attributes: { code: '' } },
        ]
      end

      it 're-renders the :complete template' do
        invalids.each do |invalid|
          current_account.reload
          put :update, { profile: new_attrs.merge(invalid) }
          expect(response).to render_template :complete
        end
      end
    end

  end
end
