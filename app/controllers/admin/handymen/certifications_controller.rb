class Admin::Handymen::CertificationsController < Admin::ApplicationController

  helper_method :tabs_info, :dashboard

  before_action :set_taxon, only: [:update, :show]

  # params
  #   page: page num
  #   certified_status:  certify state
  def index
    @search = Taxon.ransack(params[:q])
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
    state = certify_params[:certified_status]
    code = certify_params[:reason_code]
    msg = certify_params[:reason_message]

    case state
    when 'under_review'
      @taxon.pend
    when 'failure'
      @taxon.decline(current_user, code, msg)
    when 'success'
      @taxon.certify(current_user)
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

  def certify_params
    params.require(:taxon).permit(
      :certified_status,
      :reason_code,
      :reason_message)
  end
end
