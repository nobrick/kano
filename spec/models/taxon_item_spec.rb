require 'rails_helper'

RSpec.describe TaxonItem, type: :model do
  let(:taxon_item) { create :taxon_item }

  it 'creates an taxon item' do
    expect(taxon_item).to be_a TaxonItem
    expect(taxon_item).to be_persisted
  end

  it 'cannot create a taxon with invalid city code' do
    expect { create :taxon_item, city: '112233' }
      .to raise_error ActiveRecord::RecordInvalid
  end
end
