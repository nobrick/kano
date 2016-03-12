class Users::PhoneVerificationsController < ApplicationController
  attr_reader :user
  before_action :set_user, only: [ :create ]

  # POST /phone_verifications
  def create
    return unless user
    user.phone = params[:phone]
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
    SecureRandom.random_number.to_s[-4..-1]
  end

  def set_user
    @user = current_user
  end
end
