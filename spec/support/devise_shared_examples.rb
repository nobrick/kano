RSpec.shared_examples_for 'user signs in' do
  describe 'devise helper methods' do
    it '#current_account and #account_signed_in? works' do
      expect(current_account).to eq User.first
      expect(account_signed_in?).to eq true
    end

    it '#current_user and #user_signed_in? works' do
      expect(current_user).to eq User.first
      expect(user_signed_in?).to eq true
    end

    it '#current_handyman and #handyman_signed_in? returns correctly' do
      expect(current_handyman).to eq nil
      expect(handyman_signed_in?).to eq false
    end
  end

  it 'sets the session' do
    expect(session.keys).to include 'warden.user.user.key'
  end
end

RSpec.shared_examples_for 'no account signs in' do
  it 'devise helper methods work correctly' do
    %w{ current_account current_user current_handyman }.each do |method|
      expect(send method).to be nil
    end
    %w{ account_signed_in? user_signed_in? handyman_signed_in?}.each do |method|
      expect(send method).to be false
    end
  end

  it 'will not set the session' do
    expect(session.keys.any? { |k| k.match('warden') }).to eq false
  end
end
