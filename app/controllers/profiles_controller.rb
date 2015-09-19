class ProfilesController < ApplicationController
  # This controller is for filling up additional necessary user infomation
  # after signing up by omniauth.
  before_action :authenticate_user!
  before_action :set_account

  # GET /profile/edit
  def edit
  end

  # PATCH/PUT /profile/
  def update
    @account.assign_attributes(profile_params)
    if @account.save(context: :complete_info_context)
      redirect_to root_url, notice: '恭喜您成功更新个人资料。'
    else
      render :edit
    end
  end

  def set_account
    @account = current_account
  end

  def profile_params
    params.require(:profile).permit(:email, :phone, :name, :nickname)
  end
end
