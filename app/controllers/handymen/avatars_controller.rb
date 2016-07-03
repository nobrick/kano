class Handymen::AvatarsController < ApplicationController
  before_action :set_account

  def edit
  end

  def update
    avatar = profile_params[:avatar]
    if avatar.blank?
      flash[:notice] = t('.avatar_blank')
      render :edit and return
    end

    @account.avatar_crop_data = crop_data
    @account.avatar = avatar
    if @account.save
      redirect_to edit_handyman_avatar_url, notice: t('.avatar_saved')
    else
      render :edit
    end
  end

  private

  def set_account
    @account = current_account
  end

  def profile_params
    params.fetch(:profile, {})
  end

  def crop_data
    json = params[:crop_data]
    return nil if json.blank?
    ActiveSupport::JSON.decode(json).transform_keys do |key|
      key.underscore.to_sym
    end
  end
end
