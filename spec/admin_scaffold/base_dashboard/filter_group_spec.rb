require 'rails_helper'

RSpec.describe AdminScaffold::BaseDashboard::FilterGroup do
  let(:attr_class) { "TestClass" }
  let(:attributes) do
    manager = AdminScaffold::BaseDashboard::Attributes.new(attr_class)
    manager.string "account_no"
    manager.string "bank_code"
    manager.date_time "created_at"
    manager.number "total"
    manager
  end
  let(:filters_group) do
    AdminScaffold::BaseDashboard::FilterGroup.new(attributes)
  end

  context 'Define filters' do
    it 'raises error if the attr is not defined' do
      expect{ filters_group.eq("invalid", values: ["a"])}.to raise_error(AdminScaffold::ArgumentError)
      expect{ filters_group.time_range("invalid")}.to raise_error(AdminScaffold::ArgumentError)
      expect{ filters_group.range("invalid")}.to raise_error(AdminScaffold::ArgumentError)
    end
    describe '#eq' do
      context 'valid params' do
        it 'defines a select filter' do
          filters_group.eq("bank_code", values: ["a", "b", "c"])
          expect(filters_group.filter("bank_code_eq").class).to eq(AdminScaffold::Filter::Eq)
        end
      end
    end

    describe '#time_range' do
      context 'valid params' do
        it 'defines a time range filter' do
          filters_group.time_range("created_at")
          expect(filters_group.filter("created_at_time_range").class).to eq(AdminScaffold::Filter::TimeRange)
        end
      end

      context 'invalid params' do
        it 'raise error if the attr type is not DateTime' do
          expect{ filters_group.time_range("bank_code") }.to raise_error(AdminScaffold::ArgumentError)
        end
      end
    end

    describe '#range' do
      context 'valid params' do
        it 'defines a range filter' do
          filters_group.range("total")
          expect(filters_group.filter("total_range").class).to eq(AdminScaffold::Filter::Range)
        end
      end

      context 'invalid params' do
        it 'raise error if the attr type is not number' do
          expect{ filters_group.range("bank_code") }.to raise_error(AdminScaffold::ArgumentError)
        end
      end
    end
  end
end
