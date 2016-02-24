require 'rails_helper'

RSpec.describe Admin::Handymen::CertificationsController, type: :controller do
  before { sign_in :user, admin }
  let(:admin) { create :admin }
  let(:taxon) do
    create(:taxon, state: "declined")
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
        taxon

        put :update, id: taxon.id, taxon: failure_params

        taxon.reload

        expect(taxon.certified_status).to eq failure_params[:certified_status]
        expect(taxon.reason_code).to eq failure_params[:reason_code]
        expect(taxon.reason_message).to eq failure_params[:reason_message]
        expect(taxon.certified_by).to eq admin
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

        expect{ put :update, id: id, taxon: success_params }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'should fail if certified_status is not valid' do
        origin_status = taxon.certified_status

        put :update, id: taxon.id, taxon: { certified_status: "test_not_valid_status" }

        taxon.reload

        expect(taxon.certified_status).to eq origin_status
        expect(flash[:alert]).to be_present
      end

      it 'should fail if reason_code is not valid' do
        origin_code = taxon.reason_code

        put :update, id: taxon.id, taxon: { reason_code: "test_not_valid_code" }
        puts taxon.state
        puts taxon.reason_code
        puts taxon.reason_message

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
