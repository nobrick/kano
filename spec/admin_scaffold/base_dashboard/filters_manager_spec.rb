require 'rails_helper'

RSpec.describe AdminScaffold::BaseDashboard::FiltersManager do
  let(:attr_class) { "TestClass" }
  let(:attributes_manager) do
    manager = AdminScaffold::BaseDashboard::AttributesManager.new(attr_class)
    manager.string "account_no"
    manager.string "bank_code"
    manager.date_time "created_at"
    manager.number "total"
    manager
  end
  let(:filters_manager) do
    AdminScaffold::BaseDashboard::FiltersManager.new(attributes_manager, "path/a")
  end

  context 'Define filters' do
    it 'raises error if the attr is not defined' do
      expect{ filters_manager.select("invalid", ["a"])}.to raise_error(AdminScaffold::ArgumentError)
      expect{ filters_manager.radio("invalid", ["a"])}.to raise_error(AdminScaffold::ArgumentError)
      expect{ filters_manager.time_range("invalid")}.to raise_error(AdminScaffold::ArgumentError)
      expect{ filters_manager.range("invalid")}.to raise_error(AdminScaffold::ArgumentError)
    end
    describe '#select' do
      context 'valid params' do
        it 'defines a select filter' do
          filters_manager.select("bank_code", values: ["a", "b", "c"])
          expect(filters_manager.filter("bank_code").class).to eq(AdminScaffold::Filter::Select)
        end
      end
    end

    describe '#time_range' do
      context 'valid params' do
        it 'defines a time range filter' do
          filters_manager.time_range("created_at")
          expect(filters_manager.filter("created_at").class).to eq(AdminScaffold::Filter::TimeRange)
        end
      end

      context 'invalid params' do
        it 'raise error if the attr type is not DateTime' do
          expect{ filters_manager.time_range("bank_code") }.to raise_error(AdminScaffold::ArgumentError)
        end
      end
    end

    describe '#range' do
      context 'valid params' do
        it 'defines a range filter' do
          filters_manager.range("total")
          expect(filters_manager.filter("total").class).to eq(AdminScaffold::Filter::Range)
        end
      end

      context 'invalid params' do
        it 'raise error if the attr type is not number' do
          expect{ filters_manager.range("bank_code") }.to raise_error(AdminScaffold::ArgumentError)
        end
      end

    end

    describe '#radio' do
      context 'valid params' do
        it 'defines a radio filter' do
          filters_manager.radio("total")
          expect(filters_manager.filter("total").class).to eq(AdminScaffold::Filter::Radio)
        end
      end
    end
  end

  context 'Filter info' do
    describe '#filter_param' do
      it 'returns the premit params' do
      end
    end

    describe '#feedback_text' do
      it 'returns filter feedback text' do
      end
    end

    describe '#filter_form' do
      it 'returns info for viewer to create form' do
      end
    end
  end
end
