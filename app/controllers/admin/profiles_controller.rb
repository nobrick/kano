class Admin::ProfilesController < Admin::ApplicationController
  before_action :set_account

  def show
  end

  # params:
  #   id: account id
  #   profile:
  #     name:
  #     phone:
  #     nickname:
  #     gender:
  #     email:
  def update
    @account.assign_attributes(profile_params)

    if @account.save
      flash[:success] = i18n_t('update_success', 'C')
    else
      flash[:alert] = @account.errors.full_messages
    end

    redirect_to redirect_path
  end

  private

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
    @account = account_model_class.find params[:id]
  end
end
