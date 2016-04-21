require 'rails_helper'

RSpec.describe AdminScaffold::Field::DateTime do
  describe '#to_s' do
    context 'with valid data' do
      context 'with data is not nil' do
        it 'returns the data in the format defined in i18n file' do
          time = Time.now
          date_time = AdminScaffold::Field::DateTime.new("created_at", time)
          expect(date_time.to_s).to eq(I18n.l(time, format: :long))
        end
      end

      context 'with data is nil' do
        it 'returns empty string if date is nil' do
          date_time = AdminScaffold::Field::DateTime.new("created_at", nil)
          expect(date_time.to_s).to eq('')
        end
      end
    end

    context 'with invalid data' do
      it 'raise an error for the invalid data' do
          date_time = AdminScaffold::Field::DateTime.new("created_at", "invalid_data")
          expect{ date_time.to_s }.to raise_error(I18n::ArgumentError)
      end
    end
  end
end
