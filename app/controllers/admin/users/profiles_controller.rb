class Admin::Users::ProfilesController < Admin::ProfilesController
  around_action :serializable, only: [:update, :set_primary_address]
  before_action :set_account, only: [:update, :show, :set_primary_address]
  rescue_from ActiveRecord::StatementInvalid do
    redirect_to admin_user_index_path, flash: { alert: i18n_t('statement_invalid', 'RC') }
  end

  # params:
  #   id: user id
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
    assign_primary_address

    super
  end

  # params:
  #   id: user id
  #   address_id:
  def set_primary_address
    address = @account.addresses.find params[:address_id]
    @account.primary_address = address
    if @account.save
      flash[:success] = i18n_t('update_success', 'C')
    else
      flash[:alert] = @account.errors.full_messages
    end
    redirect_to admin_user_profile_path(@account)
  end

  private

  def assign_primary_address
    code = primary_address_params[:code]
    content = primary_address_params[:content]
    address = @account.addresses.where(code: code, content: content).first

    if address
      @account.primary_address = address
    else
      @account.assign_attributes(primary_address_params)
    end
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
end
