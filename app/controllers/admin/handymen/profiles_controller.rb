class Admin::Handymen::ProfilesController < Admin::ProfilesController

  def show
  end

  # params:
  #   id: handyman id
  #   profile:
  #     name:
  #     phone:
  #     nickname:
  #     gender:
  #     email:
  #     primary_address_attributes:
  #       id:
  #       code:
  #       content:
  def update
    @account.assign_attributes(primary_address_params)

    super
  end

  # params
  #   id: handyman id
  #   taxon_codes: string  for examples: "elec/id, elec/fs"
  def update_taxons
    selected_codes = (params['taxon_codes'] || '').split(',')
    codes_to_create = selected_codes - @account.taxon_codes
    codes_to_destroy = @account.taxon_codes - selected_codes
    @account.taxons.where(code: codes_to_destroy).destroy_all
    @account.taxons.create(codes_to_create.map { |e| { code: e } })

    redirect_to admin_handyman_profile_path(@account), flash: { success: i18n_t('update_success', 'C') }
  end

  private

  def primary_address_params
    params.require(:profile).permit(
      primary_address_attributes: [
        :id,
        :code,
        :content
      ]
    )
  end
end
