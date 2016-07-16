require 'rails_helper'

RSpec.describe AdminScaffold::BaseDashboard::Attributes do
  let(:resource_class) { "ResourceClass" }
  let(:attributes) { AdminScaffold::BaseDashboard::Attributes.new(resource_class) }
  context 'Define attributes' do
    let(:attr_index) { 'test_attr' }
    let(:owner_class) { 'OwnerClass' }
    describe '#string' do
      it 'defines the attr type as String' do
        attributes.string(attr_index)
        attr_class = attributes[attr_index].class
        attr_owner = attributes[attr_index].owner
        expect(attr_class).to eq(AdminScaffold::Attribute::String)
        expect(attr_owner).to eq(resource_class)
      end

      context 'with options' do
        context 'owner options' do
          it 'defines the attr owner is same as the options' do
            attributes.string(attr_index, { owner: owner_class })
            attr_owner = attributes[attr_index].owner
            expect(attr_owner).to eq(owner_class)
          end
        end
      end
    end

    describe '#date_time' do
      it 'defines the attr type as DateTime' do
        attributes.date_time(attr_index)
        attr_class = attributes[attr_index].class
        attr_owner = attributes[attr_index].owner
        expect(attr_class).to eq(AdminScaffold::Attribute::DateTime)
        expect(attr_owner).to eq(resource_class)
      end

      context 'with options' do
        context 'owner option' do
          it 'defines the attr owner is same as the options' do
            attributes.date_time(attr_index, { owner: owner_class })
            attr_owner = attributes[attr_index].owner
            expect(attr_owner).to eq(owner_class)
          end
        end
      end
    end

    describe "#number" do
      it 'defines the attr type as Number' do
        attributes.number(attr_index)
        attr_class = attributes[attr_index].class
        attr_owner = attributes[attr_index].owner
        expect(attr_class).to eq(AdminScaffold::Attribute::Number)
        expect(attr_owner).to eq(resource_class)
      end

      context 'with options' do
        context 'owner option' do
          it 'defines the attr owner is same as the options' do
            attributes.number(attr_index, { owner: owner_class })
            attr_owner = attributes[attr_index].owner
            expect(attr_owner).to eq(owner_class)
          end
        end
      end
    end

    describe "#expand" do
      it 'defines the attr type as Expand' do
        attributes.expand(attr_index, partial_path: "partial_path")
        attr_class = attributes[attr_index].class
        expect(attr_class).to eq(AdminScaffold::Attribute::Expand)
      end
    end
  end
end
