class ProfilesController < ApplicationController
  # For filling up additional necessary account infomation after sign up.
  before_action :set_account
  before_action :set_address, only: [ :complete ]

  # GET /profile/show
  def show
  end

  # GET /profile/complete
  def complete
  end

  # PATCH/PUT /profile/
  def update
    @account.assign_attributes(profile_params)
    if @account.save(context: :complete_info_context)
      redirect_to after_update_success_path,
        notice: t("^profiles.complete_success")
    else
      set_address
      yield :failure if block_given?
      render :complete
    end
  end

  private

  def after_update_success_path
    root_url
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
    params.require(:profile).permit(
      :email,
      :phone,
      :name,
      :nickname,
      primary_address_attributes: [
        :code,
        :content
      ]
    )
  end
end
