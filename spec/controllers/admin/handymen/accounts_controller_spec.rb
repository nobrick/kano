require 'rails_helper'

RSpec.describe Admin::Handymen::AccountsController, type: :controller do

  describe 'GET #show' do
    let(:handyman) { create(:handyman) }
    let(:controller_path) { 'admin/handymen/accounts' }

    context 'with invalid params' do
      it 'fails when the handyman id is not exist' do
        id_generator = Random.new()
        handyman_id = id_generator.rand(99999)
        while Handyman.ids.include?(handyman_id)
          handyman_id = id_generator.rand(99999)
        end

        get :show, id: handyman_id

        expect(flash[:alert]).to be_present
      end
    end
  end

end
