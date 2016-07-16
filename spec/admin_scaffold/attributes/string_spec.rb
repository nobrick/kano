require 'rails_helper'

RSpec.describe AdminScaffold::Attribute::String do
  describe '#to_s' do
    context 'with original_data options' do
      it 'returns orignal data' do
        attribute = AdminScaffold::Attribute::String.new('test_attr', 'tester')
        string = attribute.data("test_string", original_data: true)
        expect(string.to_s).to eq('test_string')
      end
    end

    context 'with i18n options' do
      it 'returns translated string' do
        attribute = AdminScaffold::Attribute::String.new('test_attr', 'test_owner', { i18n: true })
        string = attribute.data("test_string", original_data: true)
        expect(string.to_s).to eq(I18n.t('test_string', scope: 'test_owner.test_attrs'))
      end
    end
  end
end
