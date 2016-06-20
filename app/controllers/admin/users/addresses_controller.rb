class Admin::Users::AddressesController < Admin::ApplicationController
  around_action :serializable, only: [:update, :destroy]
  before_action :set_address, only: [:update, :destroy]

  def create
    user = User.find params[:user_id]
    address = user.addresses.new(address_params)

    if address.save
      flash[:success] = i18n_t('update_success', 'C')
    else
      flash[:alert] = address.errors.full_messages
    end

    redirect_to admin_user_profile_path(user)
  end

  def update
    @address.assign_attributes(address_params)
    if @address.save
      flash[:success] = i18n_t('update_success', 'C')
    else
      flash[:alert] = @address.errors.full_messages
    end

    redirect_to admin_user_profile_path(@address.addressable)
  end

  def destroy
    if @address.destroy
      flash[:success] = i18n_t('update_success', 'C')
    else
      flash[:alert] = @address.errors.full_messages
    end

    redirect_to admin_user_profile_path(@address.addressable)
  end

  private

  def serializable
    Address.serializable { yield }
  end

  def set_address
    @address = Address.find params[:id]
  end

  def address_params
    params.require(:address).permit(:code, :content)
  end
end
