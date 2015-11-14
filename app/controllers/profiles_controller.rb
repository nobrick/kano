class ProfilesController < ApplicationController
  # For filling up additional necessary account infomation after sign up.
  before_action :set_account
  before_action :set_address, only: [ :edit, :complete ]

  # GET /profile/edit
  def edit
  end

  # GET /profile/complete
  def complete
  end

  # PATCH/PUT /profile/
  def update
    previous_action = @account.completed_info? ? :edit : :complete
    @account.assign_attributes(profile_params)
    if @account.save(context: :complete_info_context)
      i18n_key = "controllers.profile.#{previous_action}.success"
      redirect_to root_url, notice: I18n.t(i18n_key)
    else
      set_address
      render previous_action
    end
  end

  private

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
