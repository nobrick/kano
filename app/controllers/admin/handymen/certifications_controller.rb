class Admin::Handymen::CertificationsController < Admin::ApplicationController
  helper_method :tabs_info, :dashboard

  # params
  #   page: page num
  #   certified_status:  certify state
  def index
    @taxons = Taxon.includes(:handyman).order(cert_requested_at: :desc)

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
    begin
      taxon = Taxon.find params[:id]

      result = ::Admin::CertifyTaxon.call(taxon, current_user, certified_params)

      if result.success?
        redirect_to admin_handyman_certifications_path, flash: { success: i18n_t('update_success', 'C')}
      else
        redirect_to admin_handyman_certifications_path, alert: i18n_t('update_failure', 'C', reasons: result.error)
      end

    rescue ActiveRecord::RecordNotFound
      redirect_to admin_handyman_certifications_path, alert: "技能不存在"
    end
  end

  # params
  #   id: taxon id
  def show
    @taxon = Taxon.find params[:id]
  end

  def new
    @taxon = Taxon.new
    @taxon.handyman = Handyman.new
  end

  # params
  #   taxon
  #     handyman_id: 师傅 id
  #     certified_status: 认证状态
  #     reason_code: 认证不通过原因
  #     reasom_message: 认证不通过附加信息
  #   taxon_codes: taxon 代码
  def create
    begin
      handyman = Handyman.find params[:taxon][:handyman_id]

      selected_codes = (params['taxon_codes'] || '').split(',')
      result =
        ::Admin::CreateTaxons.call(handyman, selected_codes, current_user, certified_params)

      if result.success?
        redirect_to new_admin_handyman_certification_path, notice: "创建成功"
      else
        redirect_to new_admin_handyman_certification_path, alert: result.error
      end

    rescue ActiveRecord::RecordNotFound
      redirect_to new_admin_handyman_certification_path, alert: "用户不存在"
    end
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
        path: "#"
      }
    ]
  end

  private

  def certified_params
    params.require(:taxon).permit(:certified_status, :reason_code, :reason_message)
  end
end
