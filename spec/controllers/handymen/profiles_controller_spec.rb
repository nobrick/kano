require 'rails_helper'

RSpec.describe Handymen::ProfilesController, type: :controller do
  before { sign_in :handyman, handyman }
  let(:taxon_codes_st) { 'electronic/lighting,water/faucet' }
  let(:handyman) { create :handyman }
  let(:address_attrs) do
    { primary_address_attributes: attributes_for(:address) }
  end

  describe 'GET #profile/show' do
    let(:handyman) { create :handyman_with_taxons }

    it 'returns success and renders :show' do
      get :show
      expect(response).to have_http_status(:success)
      expect(response).to render_template :show
    end
  end

  describe 'GET #profile/complete' do
    it 'returns success and renders :complete' do
      get :complete
      expect(assigns(:account)).to be current_handyman
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
        put :update, { profile: new_attrs, taxon_codes: taxon_codes_st }
        handyman.reload
        %w{ email phone name nickname }.each do |key|
          expect(handyman.send key).to eq new_attrs[key.to_sym]
        end
      end

      it 'updates the profile primary address' do
        put :update, { profile: new_attrs, taxon_codes: taxon_codes_st }
        primary_address = handyman.reload.primary_address
        expect(primary_address.content).to eq 'NEW_ADDRESS_CONTENT'
        expect(handyman.addresses).to include primary_address
      end

      it 'turns the replaced primary addresses into backup addresses' do
        expected_addresses = []
        expected_addresses << handyman.primary_address
        handyman.update!(address_attrs)
        expected_addresses << handyman.primary_address
        expect(handyman.addresses).to match_array expected_addresses

        put :update, { profile: new_attrs, taxon_codes: taxon_codes_st }
        expected_addresses << handyman.reload.primary_address
        expect(handyman.primary_address.content).to eq 'NEW_ADDRESS_CONTENT'
        expect(handyman.addresses).to match_array expected_addresses
      end
    end

    context 'with invalid params' do
      let :invalids do
        [
          { phone: '1' },
          { email: '' },
          { primary_address_attributes: { content: '' } },
        ]
      end

      it 're-renders the :complete template' do
        invalids.each do |invalid|
          current_account.reload
          hash = {
            profile: new_attrs.merge(invalid),
            taxon_codes: taxon_codes_st
          }
          put :update, hash
          expect(response).to render_template :complete
        end
      end
    end

    context 'When invalid taxon code exists' do
      it 're-renders the :complete template' do
        invalid_codes_st = 'electronic/lighting,invalid_code'
        put :update, { profile: new_attrs, taxon_codes: invalid_codes_st }
        expect(response).to render_template :complete
        expect(assigns(:account).errors.messages.keys)
          .to eq [ :'taxons.code' ]
      end
    end

  end
end
