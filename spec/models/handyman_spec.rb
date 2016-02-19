require 'rails_helper'
require 'support/payment'
require 'support/timecop'

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
      expect(handyman.taxons.certified.count).to eq 2
    end
  end

  describe '#unfrozen_balance_record' do
    it 'refers to latest record before frozen date (14 days ago)' do
      expect(handyman.unfrozen_balance_record).to eq nil

      on(15.days.ago) { create_paid_orders_for handyman, 1 }
      on(14.days.ago) { create_paid_orders_for handyman, 2 }
      handyman.reload
      record_14 = handyman.latest_balance_record
      expect(handyman.unfrozen_balance_record).to be_present
      expect(handyman.unfrozen_balance_record).to eq record_14

      on(13.days.ago) { create_paid_orders_for handyman, 1 }
      handyman.reload
      expect(handyman.unfrozen_balance_record).to be_present
      expect(handyman.unfrozen_balance_record).to eq record_14
      expect(handyman.unfrozen_balance_record)
        .not_to eq handyman.latest_balance_record
    end
  end
end
