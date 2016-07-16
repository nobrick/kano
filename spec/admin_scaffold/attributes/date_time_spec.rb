require 'rails_helper'

RSpec.describe AdminScaffold::Attribute::DateTime do
  describe '#data' do
    let(:attribute) { AdminScaffold::Attribute::DateTime.new('created_at', 'tester') }
    context 'with valid data' do
      context 'with data is not nil' do
        it 'returns the data in the format defined in i18n file' do
          time = Time.now
          date_time = attribute.data(time, original_data: true)
          expect(date_time.to_s).to eq(I18n.l(time, format: :long))
        end
      end

      context 'with data is nil' do
        it 'returns empty string if date is nil' do
          date_time = attribute.data(nil, original_data: true)
          expect(date_time.to_s).to eq('')
        end
      end
    end

    context 'with invalid data' do
      it 'raise an error for the invalid data' do
          expect{ attribute.data("invalid_data", original_data: true) }.to raise_error(I18n::ArgumentError)
      end
    end
  end
end
