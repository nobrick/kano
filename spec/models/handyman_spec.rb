require 'rails_helper'
require 'support/payment'
require 'support/timecop'

RSpec.describe Handyman, type: :model do
  let(:handyman) { create :handyman }
  let(:admin) { create :admin }

  it 'creates a handyman' do
    expect(handyman).to be_a Handyman
    expect(handyman.handyman?).to eq true
  end

  describe 'taxons' do
    let(:handyman_with_taxons) { create :handyman_with_taxons }
    let(:taxon_one) { handyman.taxons.find_by(code: 'electronic/lighting') }
    let(:attributes) do
      [
        { code: 'electronic/lighting' },
        { code: 'water/faucet' }
      ]
    end
    let(:codes) { attributes.map { |a| a[:code] } }

    it 'saves taxons' do
      handyman.taxons_attributes = attributes
      handyman.tap(&:save!).reload
      expect(handyman.taxons.first).to be_persisted
      expect(handyman.taxons.map(&:code))
        .to match_array(attributes.map {|t| t[:code]})
    end

    it 'creates taxons from FactoryGirl' do
      handyman = handyman_with_taxons
      expect(handyman.taxons.first).to be_persisted
      expect(handyman.taxons.count).to eq 2
      expect(handyman.taxons.certified.count).to eq 2
    end

    describe '#taxon_codes' do
      let(:handyman) { handyman_with_taxons }

      it 'with no arguments' do
        expect(handyman.taxon_codes).to match_array(codes)
      end

      it 'with :pending argument' do
        expect { taxon_one.pend.save! }
          .to change { handyman.reload.taxon_codes(:pending) }
          .from([]).to(%w{ electronic/lighting })
      end
    end

    describe '#taxons_redux_state' do
      let(:handyman) { handyman_with_taxons }

      it 'selectedTaxons for :pending' do
        expect { taxon_one.pend.save! }
          .to change { handyman.reload.taxons_redux_state['result']['selectedTaxons'] }
          .from([]).to(%w{ electronic/lighting })
      end

      it 'selectedTaxons for :all' do
        select = lambda do
          handyman
            .reload
            .taxons_redux_state(selected_taxons: :all)['result']['selectedTaxons']
            .sort
        end
        expect { taxon_one.pend.save! }.not_to change(select, :call).from(codes.sort)
      end
    end
  end

  describe '#unfrozen_balance_record' do
    it 'refers to latest record before frozen date (14 days ago)' do
      expect(handyman.unfrozen_balance_record).to eq nil

      on(15.days.ago) { create_paid_orders_for handyman, 1 }
      on(14.days.ago) { create_paid_orders_for handyman, 2 }
      handyman.reload
      record_14 = handyman.last_balance_record
      expect(handyman.unfrozen_balance_record).to be_present
      expect(handyman.unfrozen_balance_record).to eq record_14

      on(13.days.ago) { create_paid_orders_for handyman, 1 }
      handyman.reload
      expect(handyman.unfrozen_balance_record).to be_present
      expect(handyman.unfrozen_balance_record).to eq record_14
      expect(handyman.unfrozen_balance_record)
        .not_to eq handyman.last_balance_record
    end
  end
end
