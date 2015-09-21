require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:account) { create :account }
  let(:address_attrs) { { primary_address_attributes: attributes_for(:address) } }

  it 'creates an account' do
    expect(account).to be_persisted
  end

  describe 'has_one primary_address' do
    let(:account) { create :account, address_attrs }
    let(:primary_address) { account.primary_address }

    it 'creates primary address by assigning account primary_address attrs' do
      expect(account).to be_persisted
      expect(primary_address).to be_persisted
    end

    it 'inserts into #addresses associations' do
      expect(account.addresses).to eq [ primary_address ]
    end

    it '#primary? returns to true' do
      expect(primary_address.primary?).to eq true
    end

    it 'nullifies primary_address when destroyed' do
      expect(primary_address).to be_present
      primary_address.destroy
      expect(primary_address).to be_destroyed
      expect(account.primary_address).to be_nil
    end
  end
end
