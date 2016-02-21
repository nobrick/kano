require 'rails_helper'

RSpec.describe Withdrawal::Banking do
  subject { Withdrawal::Banking }

  describe '.banks' do
    it 'returns a banks hash' do
      expect(subject.banks).to be_a Hash
      expect(subject.banks['icbc']).to eq '工商银行'
    end
  end

  describe '.bank_codes' do
    it 'returns bank codes' do
      expect(subject.bank_codes).to be_a Array
      expect(subject.bank_codes).to include 'icbc'
    end
  end

  describe '.invert_banks' do
    it 'returns a invert banks hash' do
      expect(subject.invert_banks).to be_a Hash
      expect(subject.invert_banks['工商银行']).to eq 'icbc'
    end
  end
end
