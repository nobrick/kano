require 'rails_helper'

RSpec.describe Taxon, type: :model do
  let(:taxon) { create :taxon }
  let(:handyman) { create :handyman }

  it 'creates taxon' do
    expect(taxon).to be_a Taxon
    expect(taxon).to be_persisted
  end
end
