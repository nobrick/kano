class Admin::Handymen::CertificationsController < Admin::ApplicationController
  helper_method :tabs_info, :dashboard

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
    taxon = Taxon.find params[:id]

    taxon.assign_attributes(certified_info)

    back_url = params[:backurl]

    if taxon.save(context: :taxon_certification)
      flash[:success] = i18n_t('certify_success', 'C')
    else
      flash[:alert] = i18n_t('certify_failure', 'C', reasons: taxon.errors.full_messages)
    end

    redirect_to back_url || admin_handyman_certifications_path
  end

  # params
  #   id: taxon id
  def show
    @taxon = Taxon.find params[:id]
  end

  private

  def certified_info
    info = certified_params.merge({
      certified_by: current_user,
      certified_at: Time.now
    })

    status = info[:certified_status]

    case status
    when "success"
      info[:reason_code] = nil
      info[:reason_message] = nil
    when "under_review"
      info[:reason_code] = nil
      info[:reason_message] = nil
      info[:certified_by] = nil
      info[:certified_at] = nil
    end

    info
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

  def certified_params
    params.require(:taxon).permit(
      :certified_status,
      :reason_code,
      :reason_message)
  end
end
