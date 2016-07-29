class Admin::Users::ProfilesController < Admin::ProfilesController
  around_action :serializable, only: [:update, :set_primary_address]
  before_action :set_account, only: [:update, :show, :set_primary_address, :update_avatar]
  rescue_from ActiveRecord::StatementInvalid do
    redirect_to admin_user_index_path, flash: { alert: i18n_t('statement_invalid', 'RC') }
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

  def set_account
    @account = account_model_class.find params[:user_id]
  end
end
