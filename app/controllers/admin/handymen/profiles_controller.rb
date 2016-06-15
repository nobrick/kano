class Admin::Handymen::ProfilesController < Admin::ApplicationController
  around_action :serializable, only: [:update, :update_taxons]
  before_action :set_account, only: [:update, :show, :update_taxons]
  before_action :set_address, only: [:show]
  rescue_from ActiveRecord::StatementInvalid do
    redirect_to admin_handyman_index_path, flash: { alert: i18n_t('statement_invalid', 'RC') }
  end

  def show
  end

  # params:
  #   handyman_id: handyman id
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
    @account.assign_attributes(profile_params)

    if @account.save
      flash[:success] = i18n_t('update_success', 'C')
    else
      flash[:alert] = @account.errors.full_messages
    end

    redirect_to redirect_path
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

  def serializable
    Account.serializable { yield }
  end

  def profile_params
    params.require(:profile).permit(
      :name,
      :phone,
      :nickname,
      :gender,
      :email
    )
  end

  def redirect_path
    account_type = @account.type.downcase
    send("admin_#{account_type}_profile_path", @account)
  end

  def set_account
    @account = account_model_class.find params[:handyman_id]
  end

  def primary_address_params
    params.require(:profile).permit(
      primary_address_attributes: [
        :id,
        :code,
        :content
      ]
    )
  end

  def set_address
    address = @account.primary_address
    @account.build_primary_address(addressable: @account) if address.blank?
    @city_code = address.try(:city_code) || '431000'
    @district_code = address.try(:code) || '431001'
  end
end
