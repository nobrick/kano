class Admin::ProfilesController < Admin::ApplicationController

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

  def update_avatar
    @account.avatar = avatar_params[:avatar]
    if @account.save
      flash[:success] = "更新成功"
    else
      flash[:alert] = "更新失败"
    end
    redirect_to redirect_path
  end

  private

  def avatar_params
    params.require(:profile).permit(:avatar)
  end

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
end
