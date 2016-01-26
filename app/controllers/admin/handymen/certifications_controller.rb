class Admin::Handymen::CertificationsController < Admin::ApplicationController
  helper_method :tabs_info, :dashboard

  # params
  #   page: page num
  #   certified_status:  certify state
  def index
    @taxons = Taxon.includes(:handyman).order(cert_requested_at: :desc)

    if Taxon.certified_status.include?(params[:certified_status])
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
    taxon = Taxon.find params[:id]

    certified_attrs = certified_info(*certify_params.values)

    if taxon.update(certified_attrs)
      redirect_to admin_handyman_certifications_path, flash: { success: i18n_t('update_success', 'C')}
    else
      redirect_to admin_handyman_certifications_path, alert: i18n_t('update_failure', 'C', reasons: taxon.errors.full_messages)
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
  #   taxon_codes(Array): taxon 代码
  def create
    begin
      handyman = Handyman.find params[:taxon][:handyman_id]

      certified_attrs = certified_info(*certify_params.values)

      selected_codes = (params['taxon_codes'] || '').split(',')
      codes_to_create = selected_codes - handyman.taxon_codes
      if codes_to_create.blank?
        redirect_to new_admin_handyman_certification_path, alert: "没有选择技能或欲创建的技能已经存在"
        return
      end
      handyman.taxons.create!(codes_to_create.map { |e| { code: e }.merge(certified_attrs) })

      redirect_to new_admin_handyman_certification_path, notice: "创建成功"
    rescue ActiveRecord::RecordNotFound
      redirect_to new_admin_handyman_certification_path, alert: "用户不存在"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to new_admin_handyman_certification_path, alert: e.record.errors.full_messages
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

  def certify_params
    params.require(:taxon).permit(:certified_status, :reason_code, :reason_message)
  end

  def certified_info(status, reason_code, reason_message)
    taxon_certify_info = {
      certified_status: status,
      reason_code: reason_code,
      reason_message: reason_message
    }

    if !Taxon.certify_under_review_status?(status)
      taxon_certify_info[:certified_by] = current_user
      taxon_certify_info[:certified_at] = Time.now
    end

    if !Taxon.certify_failure_status?(status)
      taxon_certify_info[:reason_code] = nil
      taxon_certify_info[:reason_message] = nil
    end

    taxon_certify_info
  end
end
