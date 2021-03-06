class Admin::AccountsController < Admin::ApplicationController

  before_action :set_account, only: [:show]

  # params
  #   page: page num
  def index
    q_params = dashboard.search_params(params)
    @search = account_model_class.ransack(q_params)
    @accounts = @search.result.page(params[:page]).per(10)
  end

  def show
  end

  # params
  #   id: account id
  #   account_lock:  true or false
  def update
    Account.serializable do
      set_account
      if lock_account?
        @account.lock_access!
        flash[:success] = i18n_t('lock_success', 'C')
      elsif unlock_account? && @account.access_locked?
        @account.unlock_access!
        flash[:success] = i18n_t('unlock_success', 'C')
      end
    end
    redirect_to redirect_path
  end

  private

  def dashboard
    raise "Dashboard not defined"
  end

  def redirect_path
    account_type = @account.type.downcase
    send("admin_#{account_type}_profile_path", @account)
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
