require 'rails_helper'

RSpec.describe AdminScaffold::BaseDashboard::SearchManager do
  let(:attribute_manager) { AdminScaffold::BaseDashboard::AttributesManager.new("TestClass") }
  before :each do
    attribute_manager.string('string')
  end

  context 'Search define' do
    let(:search_manager) { AdminScaffold::BaseDashboard::SearchManager.new(attribute_manager, "search_path") }

    describe '#cont' do
      context 'with invlid param' do
        it 'raises error if attr is not defined' do
          expect{ search_manager.cont("str") }.to raise_error(AdminScaffold::ArgumentError)
        end
      end

      context 'with valid param' do
        it 'returns cont predicate' do
          expect(search_manager.cont("string")).to eq("string_cont")
        end
      end
    end

    describe '#eq' do
      context 'with invalid param' do
        it 'raises error if attr is not defined' do
          expect{ search_manager.eq("invalid") }.to raise_error(AdminScaffold::ArgumentError)
        end
      end

      context 'with valid param' do
        it 'returns eq predicate' do
          expect(search_manager.eq("string")).to eq("string_eq")
        end
      end
    end
  end
end
