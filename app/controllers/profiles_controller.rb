class ProfilesController < ApplicationController
  # For filling up additional necessary account infomation after sign up.
  before_action :set_account
  before_action :set_address, only: [ :edit, :complete ]
  before_action :set_view_action, only: [ :edit, :complete, :update ]

  # GET /profile/show
  def show
  end

  # GET /profile/edit
  def edit
  end

  # GET /profile/complete
  def complete
  end

  # PATCH/PUT /profile/
  def update
    @account.assign_attributes(profile_params)
    if @account.save(context: :complete_info_context)
      redirect_to root_url, notice: t("^profiles.#{@view_action}_success")
    else
      set_address
      yield :failure if block_given?
      render @view_action
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

  def set_view_action
    case action_name
    when 'update'
      @view_action = params['view_action'] == 'edit' ? 'edit' : 'complete'
    else
      @view_action = action_name
    end
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
