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
    avatar = avatar_params[:avatar]
    if avatar.blank?
      flash[:notice] = i18n_t('avatar_blank', 'C')
      render :show and return
    end

    @account.avatar_crop_data = crop_data
    @account.avatar = avatar
    if @account.save
      flash[:success] = i18n_t('avatar_update_success', 'C')
    end
    redirect_to redirect_path
  end

  private

  def crop_data
    json = params[:crop_data]
    return nil if json.blank?
    ActiveSupport::JSON.decode(json).transform_keys do |key|
      key.underscore.to_sym
    end
  end

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
