require 'rails_helper'

RSpec.describe Handymen::TaxonsController, type: :controller do
  before { sign_in :handyman, handyman }
  let(:handyman) { create :handyman }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
