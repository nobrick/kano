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
end
