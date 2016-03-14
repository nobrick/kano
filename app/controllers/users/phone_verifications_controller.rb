class Users::PhoneVerificationsController < ApplicationController
  attr_reader :user, :phone

  # POST /phone_verifications
  def create
    return unless user
    render json: { code: -1, msg: 'PHONE_IS_BLANK' } and return if phone.blank?

    user.phone = phone
    if user.valid?
      create_for_valid
    else
      render json: { code: -1, msg: user.errors.full_messages }
    end
  end

  private

  def create_for_valid
    if not_exceeding_request_limit
      render json: push_verification.slice('code', 'msg')
    else
      render json: { code: -1, msg: 'TOO_MANY_REQUESTS' }
    end
  end

  def not_exceeding_request_limit
    user.phone_vcode_sent_times_in_hour.value < 3
  end

  def push_verification
    user.phone_vcode_sent_times_in_hour.increment
    user.phone_vcode.value ||= random_code
    SMS.push_verification(user.phone, user.phone_vcode.value)
  end

  def random_code
    return phone[-4..-1] if Rails.env.development?
    SecureRandom.random_number.to_s[-4..-1]
  end

  def user
    @user ||= current_user
  end

  def phone
    @phone ||= params[:phone]
  end
end
