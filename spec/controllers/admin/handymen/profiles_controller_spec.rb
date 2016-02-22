require 'rails_helper'

RSpec.describe Admin::Handymen::ProfilesController, type: :controller do
  let(:admin) { create :admin }
  before { sign_in :user, admin }

  let(:handyman) { create(:handyman) }

  describe 'PUT #update' do
    describe 'update basic profile' do
      let(:param) do
        {
          name: "update_test",
          phone: "13112345678",
          nickname: "nickname",
          gender: "male"
        }
      end

      context 'with valid params' do
        it 'updates successful' do
          put :update, id: handyman.id, profile: param

          handyman.reload

          expect(handyman.phone).to eq param[:phone]
          expect(handyman.name).to eq param[:name]
          expect(handyman.nickname).to eq param[:nickname]
          expect(handyman.gender).to eq param[:gender]
        end
      end

      context 'with invalid params' do
        it 'fails if the handyman is not exists' do
          id_generator = Random.new()
          handyman_id = id_generator.rand(99999)
          while Handyman.ids.include?(handyman_id)
            handyman_id = id_generator.rand(99999)
          end

          expect{ put :update, id: handyman_id, profile: param }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'fails if the name is too long' do
          origin_name = handyman.name
          param[:name] = "a" * 40

          put :update, id: handyman.id, profile: param

          handyman.reload

          expect(handyman.name).to eq origin_name
        end

        it 'fails if the phone number is invalid' do
          origin_phone = handyman.phone
          param[:phone] = "9832"

          put :update, id: handyman.id, profile: param

          handyman.reload

          expect(handyman.phone).to eq origin_phone
        end
      end
    end

    describe 'update email' do
      let(:param) do
        { email: "update_email@gmail.com" }
      end
      context 'with valid params' do
        it 'updates email successfully' do
          put :update, id: handyman.id, profile: param

          handyman.reload

          expect(handyman.email).to eq param[:email]
        end
      end

      context 'with invalid params' do
        it 'fails if email exists' do
          exist_handyman = create(:handyman)
          exist_email = exist_handyman.email
          origin_email = handyman.email

          put :update, id: handyman.id, profile: { email: exist_email }

          handyman.reload

          expect(handyman.email).to eq origin_email
        end

        it 'fails if email format is invalid' do
          invalid_email = "abdx"
          origin_email = handyman.email

          put :update, id: handyman.id, profile: { email: invalid_email }

          handyman.reload

          expect(handyman.email).to eq origin_email
        end
      end
    end

    describe 'update address' do
      let(:param)  do
        {
          primary_address_attributes: {
            id: handyman.primary_address.id,
            code: '431000',
            content: "xx 街道"
          }
        }
      end
      context 'with valid address' do
        it 'update address successful' do
          put :update, id: handyman.id, profile: param

          handyman.reload

          expect(handyman.primary_address.code).to eq param[:primary_address_attributes][:code]
          expect(handyman.primary_address.content).to eq param[:primary_address_attributes][:content]
        end

        it 'does not create new address if primary_address exists' do
          # 因为handyman 是 lazy load，如果不提前调用，其会在 expect 的时候才会创建
          # 同样 handyman 的 address 也会在这个时候创建，所以 expect 就不正确
          handyman

          expect{ put :update, id: handyman.id, profile: param }.not_to change{ Address.count }

        end

        it 'create new address if primary_address not exists' do
          param[:primary_address_attributes][:id] = nil
          handyman.primary_address.destroy

          expect{ put :update, id: handyman.id, profile: param}.to change{ Address.count }.by(1)
        end
      end

      context 'with invalid address' do
        it 'fails if the code is invalid' do
          param[:primary_address_attributes][:code] = 'sd000'
          origin_code = handyman.primary_address.code

          put :update, id: handyman.id, profile: param

          handyman.reload

          expect(handyman.primary_address.code).to eq origin_code
        end

        it 'fails if the content is empty' do
          param[:primary_address_attributes][:content] = ""
          origin_content = handyman.primary_address.content

          put :update, id: handyman.id, profile: param

          handyman.reload

          expect(handyman.primary_address.content).to eq origin_content
        end
      end
    end
  end

  describe 'PUT #update_taxons' do
    let(:param) { 'electronic/lighting' }
    context 'with valide params' do
      it 'updates successful' do
        put :update_taxons, id: handyman.id, taxon_codes: param

        new_taxons = handyman.taxons.last

        expect(new_taxons.code).to eq param
      end
    end

    context 'with invalid params' do
      it 'fails if the taxon_codes is invalid' do
        expect { put :update_taxons, id: handyman.id, taxon_codes: "s/c"}.not_to change{handyman.taxons.count}
      end
    end
  end
end
