require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:user) { create :user }
  let(:attrs) { { addressable: user, code: '430105', content: '德雅路01号' } }
  let(:address) { Address.create! attrs }

  it 'creates an address' do
    expect(address).to be_persisted
    expect(create :address).to be_persisted
  end

  it 'assigns additonal attrs by setting area code' do
    expect(address.province).to eq '湖南省'
    expect(address.city).to eq '长沙市'
    expect(address.district).to eq '开福区'
    expect(address.district_with_prefix).to eq '湖南省长沙市开福区'
  end

end
