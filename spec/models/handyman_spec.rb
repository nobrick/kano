require 'rails_helper'

RSpec.describe Handyman, type: :model do
  let(:handyman) { create :handyman }

  it 'creates a handyman' do
    expect(handyman).to be_a Handyman
    expect(handyman.handyman?).to eq true
  end

  describe 'taxons' do
    let(:handyman_with_taxons) { create :handyman_with_taxons }
    let(:attributes) do
      [
        { code: 'electronic/lighting' },
        { code: 'water/faucet' }
      ]
    end

    it 'saves taxons' do
      handyman.taxons_attributes = attributes
      handyman.tap(&:save!).reload
      expect(handyman.taxons.first).to be_persisted
      expect(handyman.taxons.map(&:code))
        .to match_array(attributes.map {|t| t[:code]})
    end

    it 'creates taxons from FactoryGirl' do
      handyman = create :handyman_with_taxons
      expect(handyman.taxons.first).to be_persisted
      expect(handyman.taxons.count).to eq 2
    end
  end
end
