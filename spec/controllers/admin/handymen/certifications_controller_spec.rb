require 'rails_helper'

RSpec.describe Admin::Handymen::CertificationsController, type: :controller do
  before { sign_in :user, admin }
  let(:admin) { create :admin }
  let(:taxon) do
    create(:certified_taxon, {
      certified_status: "failure",
      reason_code: "out_of_date",
      reason_message: "out_of_date_msg"
    })
  end

  let(:success_params)  do
    {
      certified_status: "success"
    }
  end

  let(:failure_params) do
    {
      certified_status: "failure",
      reason_code: "missing_info",
      reason_message: "missing_info_msg"
    }
  end

  describe 'GET #index' do
    it 'should return 200 http status' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:handyman) { create :handyman }
    let(:taxon_code) do
      'electronic/lighting'
    end
    let(:taxon_codes) do
      'electronic/lighting,water/faucet'
    end
    context 'with valid params' do
      it 'creates a new taxon' do
        expect do
          post :create, taxon: { handyman_id: handyman.id }, taxon_codes: taxon_code
        end.to change { handyman.taxons.count }.by 1
      end

      it 'creates sevaral taxons' do
        expect do
          post :create, taxon: { handyman_id: handyman.id }, taxon_codes: taxon_codes
        end.to change { handyman.taxons.count }.by 2
      end

      context 'with certification' do
        it 'creates a new certified taxon' do
          param = { handyman_id: handyman.id }.merge(failure_params)

          expect do
            post :create, taxon: param, taxon_codes: taxon_code
          end.to change { handyman.taxons.count }.by 1

          new_taxon = handyman.taxons.order("created_at DESC").first
          expect(new_taxon.certified_status).to eq failure_params[:certified_status]
          expect(new_taxon.certified_by).to eq admin
          expect(new_taxon.reason_code).to eq failure_params[:reason_code]
          expect(new_taxon.reason_message).to eq failure_params[:reason_message]
        end

        it 'creates sevaral certified taxons' do
          param = { handyman_id: handyman.id }.merge(failure_params)

          expect do
            post :create, taxon: param, taxon_codes: taxon_codes
          end.to change { handyman.taxons.count }.by 2

          new_taxon_one = handyman.taxons.order("created_at DESC")[0]
          expect(new_taxon_one.certified_status).to eq failure_params[:certified_status]
          expect(new_taxon_one.certified_by).to eq admin
          expect(new_taxon_one.reason_code).to eq failure_params[:reason_code]
          expect(new_taxon_one.reason_message).to eq failure_params[:reason_message]

          new_taxon_two = handyman.taxons.order("created_at DESC")[1]
          expect(new_taxon_two.certified_status).to eq failure_params[:certified_status]
          expect(new_taxon_two.certified_by).to eq admin
          expect(new_taxon_two.reason_code).to eq failure_params[:reason_code]
          expect(new_taxon_two.reason_message).to eq failure_params[:reason_message]

        end
      end
    end

    context 'with invalid params' do
      it 'fails when handyman not exists' do
        id_generator = Random.new()
        handyman_id = id_generator.rand(99999)
        while Handyman.ids.include?(handyman_id)
          handyman_id = id_generator.rand(99999)
        end

        post :create, taxon: { handyman_id: handyman_id }, taxon_codes: taxon_code

        expect(flash[:alert]).to be_present
      end

      it 'fails when taxon_code invalid' do
        post :create, taxon: { handyman_id: handyman.id }, taxon_codes: 'invalid_code'

        expect(flash[:alert]).to be_present
      end

      context 'with certifications' do
        it 'fails when certified_status invalid' do
          param = { handyman_id: handyman.id, certified_status: "invalid_status" }

          post :create, taxon: param, taxon_codes: taxon_code

          expect(flash[:alert]).to be_present
        end

        it 'fails when reason_code invalid' do
          param = { handyman_id: handyman.id }.merge(failure_params)
          param[:reason_code] = "invalid_reason_code"

          post :create, taxon: param, taxon_codes: taxon_code

          expect(flash[:alert]).to be_present
        end

        it 'fails when certified_status is failure but no reason_code' do
          param = { handyman_id: handyman.id }.merge(failure_params)
          param.delete(:reason_code)

          post :create, taxon: param, taxon_codes: taxon_code

          expect(flash[:alert]).to be_present
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'should update the certified status to success' do
        put :update, id: taxon.id, taxon: success_params

        taxon.reload

        expect(taxon.certified_status).to eq success_params[:certified_status]
        expect(taxon.certified_by).to eq admin
        expect(taxon.reason_code).to eq nil
        expect(taxon.reason_message).to eq nil
        expect(flash[:success]).to be_present
      end

      it 'should update the certified status to failure' do
        put :update, id: taxon.id, taxon: failure_params

        taxon.reload

        expect(taxon.certified_status).to eq failure_params[:certified_status]
        expect(taxon.certified_by).to eq admin
        expect(taxon.reason_code).to eq failure_params[:reason_code]
        expect(taxon.reason_message).to eq failure_params[:reason_message]
        expect(flash[:success]).to be_present
      end

      it 'should not be certified if the status is under_review' do
        put :update, id: taxon.id, taxon: { certified_status: "under_review" }

        taxon.reload

        expect(taxon.certified_status).to eq "under_review"
        expect(taxon.certified_by).to eq nil
        expect(taxon.reason_code).to eq nil
        expect(taxon.reason_message).to eq nil
        expect(flash[:success]).to be_present
      end
    end

    context 'with invalid params' do
      it 'should fail if taxon is not exist' do
        id_generator = Random.new()
        id = id_generator.rand(99999)
        while Taxon.ids.include?(id)
          id = id_generator.rand(99999)
        end

        put :update, id: id, taxon: success_params

        expect(flash[:alert]).to be_present
      end

      it 'should fail if certified_status is not valid' do
        origin_status = taxon.certified_status

        put :update, id: taxon.id, taxon: { certified_status: "test_not_valid_status" }

        taxon.reload

        expect(taxon.certified_status).to eq origin_status
        expect(flash[:alert]).to be_present
      end

      it 'should fail if certified_status is not present' do
        failure_params.delete(:certified_status)
        origin_status = taxon.certified_status
        origin_code = taxon.reason_code
        origin_message = taxon.reason_message

        put :update, id: taxon.id, taxon: failure_params

        taxon.reload

        expect(flash[:alert]).to be_present
        expect(taxon.certified_status).to eq origin_status
        expect(taxon.reason_code).to eq origin_code
        expect(taxon.reason_message).to eq origin_message
      end

      it 'should fail if reason_code is not valid' do
        origin_code = taxon.reason_code

        put :update, id: taxon.id, taxon: { reason_code: "test_not_valid_code" }

        taxon.reload

        expect(taxon.reason_code).to eq origin_code
        expect(flash[:alert]).to be_present
      end

      it 'should not update the reason_code and reason_message if status is success' do
        success_params[:reason_code] = "missing_info"
        success_params[:reason_message] = "missing_info"

        put :update, id: taxon.id, taxon: success_params

        taxon.reload

        expect(taxon.certified_status).to eq "success"
        expect(taxon.reason_code).to eq nil
        expect(taxon.reason_message).to eq nil
      end

      it 'should fail if status is failure but has no reason_code' do
        taxon.update!(certified_status: "success", reason_code: nil, reason_message:nil, certified_by: admin)
        failure_params.delete(:reason_code)

        put :update, id: taxon.id, taxon: failure_params

        taxon.reload

        expect(flash[:alert]).to be_present
        expect(taxon.certified_status).to eq "success"
        expect(taxon.reason_message).to eq nil
      end
    end
  end
end
