require 'rails_helper'

RSpec.describe Taxon, type: :model do
  let(:taxon) { create :taxon, code: code }
  let(:code) { 'electronic/lighting' }
  let(:expected_name) { '灯具维修' }
  let(:expected_category_name) { '电' }
  let(:handyman) { create :handyman }

  it 'self.taxon_name translates taxon key' do
    expect(Taxon.taxon_name(code)).to eq expected_name
    expect(Taxon.taxon_name('electronic', 'lighting')).to eq expected_name
  end

  it 'self.category_name traslates category key' do
    expect(Taxon.category_name('electronic')).to eq expected_category_name
  end

  it 'creates cert-pending taxon' do
    expect { taxon }.to change(Taxon.pending, :count).by 1
    expect(taxon).to be_persisted
    expect(taxon.pending?).to eq true
  end

  it '#name' do
    expect(taxon.name).to eq expected_name
  end

  it '#category_name' do
    expect(taxon.category_name).to eq expected_category_name
  end

  it '#reason_code_desc' do
    taxon.reason_code = 'missing_info'
    expect(taxon.reason_code_desc).to eq '资料不全'
  end

  describe 'FactoryGirl methods' do
    it 'creates pending taxon' do
      taxon = create :taxon, state: :pending
      expect(taxon.pending?).to eq true
      expect(taxon.state).to eq 'under_review'
      expect(Taxon.pending).to eq [ taxon ]
    end

    it 'creates certified taxon' do
      taxon = create :taxon, state: :certified
      expect(taxon.certified?).to eq true
      expect(taxon.state).to eq 'success'
      expect(Taxon.certified).to eq [ taxon ]
    end

    it 'creates declined taxon' do
      taxon = create :taxon, state: :declined
      expect(taxon.declined?).to eq true
      expect(taxon.state).to eq 'failure'
      expect(Taxon.declined).to eq [ taxon ]
    end
  end
end
