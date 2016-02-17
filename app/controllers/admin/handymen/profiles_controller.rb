class Admin::Handymen::ProfilesController < Admin::ApplicationController

  before_action :set_handyman

  # params:
  #   id: handyman id
  #   profile:
  #     name:
  #     phone:
  #     nickname:
  #     gender:
  #     email:
  #     primary_address:
  #       id:
  #       code:
  #       content:
  def update
    @handyman.assign_attributes(profile_params)

    if @handyman.save
      flash[:success] = i18n_t('update_success', 'C')
    else
      flash[:alert] = @handyman.errors.full_messages
    end
    redirect_to admin_handyman_account_path(@handyman)
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

    redirect_to admin_handyman_account_path(@handyman), flash: { success: i18n_t('update_success', 'C') }
  end

  # params
  #   id: handyman id
  #   account_lock:  true or false
  def update_account_status
    if lock_account?
      @handyman.lock_access!
      flash[:success] = i18n_t('lock_success', 'C')
    elsif unlock_account? && @handyman.access_locked?
      @handyman.unlock_access!
      flash[:success] = i18n_t('unlock_success', 'C')
    end

    redirect_to admin_handyman_account_path(@handyman)
  end

  private

  def lock_account?
    params[:account_lock] == 'true'

  end

  def unlock_account?
    params[:account_lock] == 'false'
  end

  def profile_params
    params.require(:profile).permit(
      :name,
      :phone,
      :nickname,
      :gender,
      :email,
      primary_address_attributes: [
        :id,
        :code,
        :content
      ]
    )
  end

  def set_handyman
    @handyman = Handyman.find params[:id]
  end
end
