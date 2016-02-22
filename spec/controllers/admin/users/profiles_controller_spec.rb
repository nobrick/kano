require 'rails_helper'

RSpec.describe Admin::Users::ProfilesController, type: :controller do

  let(:admin) { create :admin }
  before { sign_in :user, admin }

  let(:user) { create(:user) }

  describe 'PUT #update' do
    context 'update basic profile' do
      let(:param) do
        {
          name: "update_name",
          phone: "13512341234",
          nickname: "update_nick_name",
          gender: "female",
        }
      end

      it 'updates basic profile successful' do
        put :update, id: user.id, profile: param

        user.reload

        expect(user.name).to eq param[:name]
        expect(user.phone).to eq param[:phone]
        expect(user.nickname).to eq param[:nickname]
        expect(user.gender).to eq param[:gender]
      end
    end

    context 'update email' do
      let(:param) do
        {
          email: "update_email@gmail.com"
        }
      end

      it 'updates email successful' do
        put :update, id: user.id, profile: param

        user.reload

        expect(user.email).to eq param[:email]
      end
    end
  end
end
