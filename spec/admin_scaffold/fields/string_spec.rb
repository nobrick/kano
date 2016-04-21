require 'rails_helper'

RSpec.describe AdminScaffold::Field::String do
  describe '#to_s' do
    context 'without i18n options' do
      it 'returns orignal data' do
        string = AdminScaffold::Field::String.new('test_attr', 'test_string')
        expect(string.to_s).to eq('test_string')
      end
    end

    context 'with i18n options' do
      context 'without defining the i18n scope' do
        it 'returns translated string in the attribute scope' do
          string = AdminScaffold::Field::String.new('test_attr', 'test_string', { i18n: true })
          expect(string.to_s).to eq(I18n.t('test_string', scope: 'test_attr'))

        end
      end

      context 'defined the i18n scope' do
        it 'returns translated string in the scope defined' do
          string = AdminScaffold::Field::String.new('test_attr', 'test_string', { i18n: true, i18n_scope: 'abc' })
          expect(string.to_s).to eq(I18n.t('test_string', scope: 'abc'))
        end
      end
    end
  end
end
