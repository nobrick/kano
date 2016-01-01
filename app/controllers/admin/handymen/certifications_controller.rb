class Admin::Handymen::CertificationsController < Admin::ApplicationController
  before_action :ensuren_current_params, only: :update

  def index
    @taxons = Taxon.all.order(:created_at)
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
    }

    if Taxon.certify_fail_status?(certify_params[:certified_status])
      certified_info.merge!(certify_params)
    else
      certified_info.merge!(
        certified_status: certify_params[:certified_status],
        reason_code: nil,
        reason_message: nil,
      )
    end

    taxon.update(certified_info)

    redirect_to admin_handyman_certifications_path
  end

  # params
  #   id: taxon id
  def show
    @taxon = Taxon.find params[:id]
  end

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

  #TODO 怎么更好的返回 400
  def ensuren_current_params
    status = certify_params[:certified_status]
    reason_code = certify_params[:reason_code]

    if !Taxon.status_correct?(status)
      head :bad_request
      return
    end

    if !reason_code.blank? && !Taxon.reason_code_correct?(reason_code)
      head :bad_request
      return
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
