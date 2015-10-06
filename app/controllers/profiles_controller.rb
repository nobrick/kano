class ProfilesController < ApplicationController
  # This controller is for filling up additional necessary user infomation
  # after signing up by omniauth.
  before_action :authenticate_user!
  before_action :set_account

  # GET /profile/edit
  def edit
    set_address
  end

  # PATCH/PUT /profile/
  def update
    @account.assign_attributes(profile_params)
    if @account.save(context: :complete_info_context)
      redirect_to root_url, notice: '恭喜您成功更新个人资料。'
    else
      set_address
      render :edit
    end
  end

  def set_account
    @account = current_account
  end

  def set_address
    address = @account.primary_address
    @account.build_primary_address(addressable: @account) if address.blank?
    @city_code = address.try(:city_code) || '430100'
    @district_code = address.try(:code)
  end

  def profile_params
    params.require(:profile)
      .permit(:email, :phone, :name, :nickname,
    primary_address_attributes: [ :code, :content ] )
  end
end
