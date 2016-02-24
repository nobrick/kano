class Admin::AccountsController < Admin::ApplicationController

  before_action :set_account, only: [:update_account_status, :show]

  # params
  #   page: page num
  def index
    @search = account_model_class.ransack(params[:q])
    @accounts = @search.result.page(params[:page]).per(10)
  end

  def show
  end

  # params
  #   id: account id
  #   account_lock:  true or false
  def update_account_status
    if lock_account?
      @account.lock_access!
      flash[:success] = i18n_t('lock_success', 'C')
    elsif unlock_account? && @account.access_locked?
      @account.unlock_access!
      flash[:success] = i18n_t('unlock_success', 'C')
    end

    redirect_to redirect_path
  end

  private

  def redirect_path
    account_type = @account.type.downcase
    send("admin_#{account_type}_account_path", @account)
  end

  def set_account
    @account = account_model_class.find params[:id]
  end

  def lock_account?
    params[:account_lock] == 'true'

  end

  def unlock_account?
    params[:account_lock] == 'false'
  end
end
