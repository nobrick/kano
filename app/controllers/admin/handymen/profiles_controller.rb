class Admin::Handymen::ProfilesController < Admin::ApplicationController
  before_action :set_handyman

  # params:
  #   id: handyman id
  #   profile:
  #     name:
  #     phone:
  #     nickname:
  #     gender:
  def update_basic_profile
    @handyman.assign_attributes(profile_params)

    if @handyman.save
      redirect_to admin_handyman_account_path(@handyman), flash: { success: "success" }
    else
      redirect_to admin_handyman_account_path(@handyman), alert: @handyman.errors.full_messages
    end
  end

  # params
  #   id: handyman id
  #   profile:
  #     primary_address:
  #       id:
  #       code:
  #       content:
  def update_address
    @handyman.assign_attributes(address_params)

    if @handyman.save
      redirect_to admin_handyman_account_path(@handyman), flash: { success: "success" }
    else
      redirect_to admin_handyman_account_path(@handyman), alert: @handyman.errors.full_messages
    end
  end

  # params
  #   id: handyman id
  #   profile:
  #     email
  def update_email
    @handyman.assign_attributes(email_params)

    if @handyman.save
      redirect_to admin_handyman_account_path(@handyman), flash: { success: "success" }
    else
      redirect_to admin_handyman_account_path(@handyman), alert: @handyman.errors.full_messages
    end
  end

  # params
  #   id: handyman id
  #   taxon_codes: string  for examples: "elec/id, elec/fs"
  def update_taxons
    selected_codes = (params['taxon_codes'] || '').split(',')
    codes_to_create = selected_codes - @handyman.taxon_codes
    codes_to_destroy = @handyman.taxon_codes - selected_codes
    @handyman.taxons.where(code: codes_to_destroy).destroy_all
    @handyman.taxons.create(codes_to_create.map { |e| { code: e } })

    redirect_to admin_handyman_account_path(@handyman), flash: { success: "success" }
  end

  private

  def address_params
    params.require(:profile).permit(
      primary_address_attributes: [
      :id,
      :code,
      :content
    ])
  end

  def email_params
    params.require(:profile).permit(:email)
  end

  def profile_params
    params.require(:profile).permit(
      :name,
      :phone,
      :nickname,
      :gender
    )
  end

  def set_handyman
    @handyman = Handyman.find params[:id]
  end
end
