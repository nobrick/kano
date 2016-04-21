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
      it 'returns translated string' do
        string = AdminScaffold::Field::String.new('test_attr', 'test_string', { i18n: { attr_owner: 'test_owner' }})
        expect(string.to_s).to eq(I18n.t('test_string', scope: 'test_owner.test_attr'))
      end
    end
  end
end
