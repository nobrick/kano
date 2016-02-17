require 'rails_helper'
RSpec.describe AdminValidator do
  before do
    stub_const('Foo', Class.new)
    Foo.class_eval do
      include ActiveModel::Validations
      attr_accessor :account
    end
  end

  shared_examples_for 'admin validatable' do
    context 'With admin' do
      it 'is valid' do
        subject.account = create :admin
        expect(subject).to be_valid
      end
    end

    context 'With non-admin' do
      it 'is invalid' do
        subject.account = create :user
        expect(subject).to be_invalid
      end
    end
  end

  context 'With no :presence option set' do
    before { Foo.class_eval { validates :account, admin: true } }
    subject { Foo.new }
    it_behaves_like 'admin validatable'

    context 'Without admin' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  context 'With :presence option set' do
    before { Foo.class_eval { validates :account, admin: { presence: true } } }
    subject { Foo.new }
    it_behaves_like 'admin validatable'

    context 'Without admin' do
      it 'is valid' do
        expect(subject).to be_invalid
      end
    end
  end
end
