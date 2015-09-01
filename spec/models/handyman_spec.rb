require 'rails_helper'

RSpec.describe Handyman, type: :model do
  let(:handyman) { create :handyman, email: 'john@email.com' }

  it 'creates a handyman' do
    expect(handyman).to be_a Handyman
    expect(handyman.handyman?).to eq true
  end
end
