class Admin::Handymen::CertificationsController < Admin::ApplicationController
  before_action :ensuren_current_params, only: :update

  # params
  #   page: page num
  #   certified_status:  certify state

  def index
    tmp_taxons = Taxon.includes(:handyman).order(cert_requested_at: :desc)

    if Taxon.certified_status.include?(params[:certified_status])
      tmp_taxons = tmp_taxons.where(certified_status: params[:certified_status])
    end
    @taxons = tmp_taxons.page(params[:page]).per(10)
  end

  # params
  #   id: taxon id
  #   taxon[:certified_status]: certified_status
  #   taxon[:reason_code]: fail reason code
  #   taxon[:reason_message]: fail reason message
  def update
    taxon = Taxon.find params[:id]

    certified_info = {
      certified_by: current_user,
      certified_at: Time.now,
    }.merge(certify_params)

    # TODO  use helper to implement t method
    if taxon.update(certified_info)
      redirect_to admin_handyman_certifications_path, flash: { success: i18n_t('update_success', 'C')}
    else
      redirect_to admin_handyman_certifications_path, alert: i18n_t('update_failure', 'C')
    end
  end

  # params
  #   id: taxon id
  def show
    @taxon = Taxon.find params[:id]
  end


  helper_method :dashboard

  def dashboard
    @dashboard ||= ::CertifyDashboard.new
  end

  # TODO wtf 怎么把 tabs_info 和 certified_status 这些显示元素去掉?
  helper_method :tabs_info, :certified_status_filter

  def certified_status_filter
    Taxon.certified_status
  end

  def tabs_info
    [
      {
        text: "技能认证管理",
        path: admin_handyman_certifications_path
      },
      {
        text: "师傅信息管理",
        path: "#"
      }
    ]
  end

  private

  def ensuren_current_params
    status = certify_params[:certified_status]
    if !Taxon.certify_failure_status?(status)
      params[:taxon][:reason_code] = nil
      params[:taxon][:reason_message] = nil
    end
  end

  def certify_params
    params.require(:taxon).permit(
      :certified_status,
      :reason_code,
      :reason_message
    )
  end
end
