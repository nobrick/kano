require 'rails_helper'

RSpec.describe AdminScaffold::BaseDashboard::AttributesManager do
  let(:attr_class) { "TestClass" }
  let(:attribute_manager) { AdminScaffold::BaseDashboard::AttributesManager.new(attr_class) }
  context 'Attributes Define' do
    let(:attr) { 'test_attr' }
    let(:other_class) { 'AnotherClass' }
    describe '#string' do
      context 'without options' do
        it 'defines the attr type as String' do
          attribute_manager.string(attr)
          data_type = attribute_manager.attributes[attr].type
          attr_owner = attribute_manager.attributes[attr].owner
          expect(data_type).to eq(AdminScaffold::Field::String)
          expect(attr_owner).to eq(attr_class)
        end
      end

      context 'with options' do
        context 'owner options' do
          it 'defines the attr owner is same as the options' do
            attribute_manager.string(attr, { owner: other_class })
            attr_owner = attribute_manager.attributes[attr].owner
            expect(attr_owner).to eq(other_class)
          end
        end
      end
    end

    describe '#date_time' do
      context 'without options' do
        it 'defines the attr type as DateTime' do
          attribute_manager.date_time(attr)
          data_type = attribute_manager.attributes[attr].type
          attr_owner = attribute_manager.attributes[attr].owner
          expect(data_type).to eq(AdminScaffold::Field::DateTime)
          expect(attr_owner).to eq(attr_class)
        end
      end

      context 'with options' do
        context 'owner option' do
          it 'defines the attr owner is same as the options' do
            attribute_manager.date_time(attr, { owner: other_class })
            attr_owner = attribute_manager.attributes[attr].owner
            expect(attr_owner).to eq(other_class)
          end
        end
      end
    end

    describe "#number" do
      context 'without options' do
        it 'defines the attr type as Number' do
          attribute_manager.number(attr)
          data_type = attribute_manager.attributes[attr].type
          attr_owner = attribute_manager.attributes[attr].owner
          expect(data_type).to eq(AdminScaffold::Field::Number)
          expect(attr_owner).to eq(attr_class)
        end
      end

      context 'with options' do
        context 'owner option' do
          it 'defines the attr owner is same as the options' do
            attribute_manager.number(attr, { owner: other_class })
            attr_owner = attribute_manager.attributes[attr].owner
            expect(attr_owner).to eq(other_class)
          end
        end
      end
    end
  end
end
