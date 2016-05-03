require 'rails_helper'

RSpec.describe AdminScaffold::BaseDashboard::Attribute do
  describe '.new' do
    context 'invalid params' do
      context 'Expand type' do
        it 'raises error when does not define the partial_path' do
          expect{ AdminScaffold::BaseDashboard::Attribute.new("created_at", "User", AdminScaffold::Field::Expand) }
            .to raise_error /partial_path should be defined/
        end
      end
    end
  end

  describe '#data' do
    context 'without options' do
      it 'returns the type that defined' do
        attr = AdminScaffold::BaseDashboard::Attribute.new("created_at", "User", AdminScaffold::Field::DateTime)
        expect(attr.data.deferred_class).to eq(AdminScaffold::Field::DateTime)
      end
    end

    context 'with options' do
      it 'returns the deferred with class is type that defined' do
        attr = AdminScaffold::BaseDashboard::Attribute.new("created_at", "User", AdminScaffold::Field::DateTime, { format: :long })
        expect(attr.data.deferred_class).to eq(AdminScaffold::Field::DateTime)
      end
    end
  end

  describe '#name' do
    context 'no expand attr' do
      it 'returns the attr name that been translated' do
        attr = AdminScaffold::BaseDashboard::Attribute.new("created_at", "User", AdminScaffold::Field::DateTime)
        expect(attr.name).to eq(I18n.t("created_at", scope: [:activerecord, :attributes, :user]))
      end
    end

    context 'expand attr' do
      let(:partial_path) { "admin/withdrawals" }
      context 'without name option' do
        it 'returns blank string' do
          attr = AdminScaffold::BaseDashboard::Attribute.new("created_at", "User", AdminScaffold::Field::Expand, { partial_path: partial_path })
          expect(attr.name).to eq('')
        end
      end
    end

    describe '#partial_path' do
      let(:partial_path) { "admin/withdrawals" }
      context 'not expand attr' do
        it 'returns empty string' do
          attr = AdminScaffold::BaseDashboard::Attribute.new("created_at", "User", AdminScaffold::Field::DateTime)
          expect(attr.partial_path).to eq('')
        end
      end

      context 'expand attr' do
        it 'returns the partial path that defined' do
          attr = AdminScaffold::BaseDashboard::Attribute.new("created_at", "User", AdminScaffold::Field::Expand, { partial_path: partial_path })
          expect(attr.partial_path).to eq(partial_path + "/user_created_at_table_header")
        end
      end
    end
  end
end
