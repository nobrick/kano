class Admin::Handymen::CertificationsController < Admin::ApplicationController

  helper_method :tabs_info, :dashboard

  before_action :set_taxon, only: [:update, :show]

  # params
  #   page: page num
  #   certified_status:  certify state
  def index
    q_params = ransack_params_for(:handyman_name_cont, :handyman_id_eq)
    @search = Taxon.ransack(q_params)
    @taxons = @search.result.includes(:handyman).order(cert_requested_at: :desc)

    if Taxon.certified_statuses.include?(params[:certified_status])
      @taxons = @taxons.where(certified_status: params[:certified_status])
    end

    @taxons = @taxons.page(params[:page]).per(10)
  end

  # params
  #   id: taxon id
  #   taxon[:certified_status]: certified_status
  #   taxon[:reason_code]: fail reason code
  #   taxon[:reason_message]: fail reason message
  def update
    back_url = params[:backurl]

    if certify_taxon
      flash[:success] = i18n_t('certify_success', 'C')
    else
      flash[:alert] = i18n_t('certify_failure', 'C', reasons: @taxon.errors.full_messages)
    end

    redirect_to back_url || admin_handyman_certifications_path
  end

  # params
  #   id: taxon id
  def show
  end

  private

  def certify_taxon
    case cert_params[:certified_status]
    when 'under_review'
      @taxon.pend.save
    when 'failure'
      @taxon.declined_by = current_user
      @taxon.decline(cert_params.slice(:reason_code, :reason_message)).save
    when 'success'
      @taxon.certify(certified_by: current_user).save
    else
      false
    end
  end

  def set_taxon
    @taxon = Taxon.find params[:id]
  end

  def dashboard
    @dashboard ||= ::CertifyDashboard.new
  end

  def tabs_info
    [
      {
        text: "技能认证管理",
        path: admin_handyman_certifications_path
      },
      {
        text: "师傅信息管理",
        path: admin_handyman_accounts_path
      }
    ]
  end

  def status_param
    params.require(:taxon).permit(:certified_status)
  end

  def cert_params
    params.require(:taxon).permit(
      :certified_status,
      :reason_code,
      :reason_message)
  end
end
