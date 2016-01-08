class Admin::Handymen::CertificationsController < Admin::ApplicationController
  before_action :ensuren_current_params, only: :update

  # params
  #   page: page num
  #   certified_status:  certify state

  def index
    tmp_taxons = Taxon.order(:cert_requested_at)

    if Taxon.certified_status.include?(params[:certified_status])
      tmp_taxons = tmp_taxons.where(certified_status: params[:certified_status])
    end
    @taxons = tmp_taxons.page(params[:page])
  end

  # params
  #   id: taxon id
  #   taxon[:certified_status]: certified_status
  #   taxon[:reason_code]: fail reason code
  #   taxon[:reason_message]: fail reason message
  def update
    taxon = Taxon.find params[:id]

    certified_info = {
      certified_by: current_user.id,
      certified_at: Time.now,
    }.merge(certify_params)

    # TODO  use helper to implement t method
    if taxon.update(certified_info)
      puts "fuck here"
      redirect_to admin_handyman_certifications_path, notice: I18n.t('controllers.admin.handymen/certification.update_success')
    else
      puts certified_info.to_s
      redirect_to admin_handyman_certifications_path, notice: I18n.t('controllers.admin.handymen/certification.update_fail', reasons: taxon.errors.full_messages.join('；'))
    end
  end

  # params
  #   id: taxon id
  def show
    @taxon = Taxon.find params[:id]
  end


  # TODO wtf
  helper_method :tabs_info

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
    if Taxon.certify_fail_status?(status)
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
