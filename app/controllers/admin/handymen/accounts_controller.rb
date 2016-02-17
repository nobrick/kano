class Admin::Handymen::AccountsController < Admin::ApplicationController

  helper_method :dashboard, :tabs_info

  before_action :set_handyman, only: [:show]

  # params
  #   page: page num
  def index
    @handymen = Handyman.page(params[:page]).per(10)
  end

  # params
  #   id: handyman id
  def show
    set_address
  end

  private

  def set_handyman
    @handyman = Handyman.find params[:id]
  end

  def set_address
    address = @handyman.primary_address
    @handyman.build_primary_address(addressable: @handyman) if address.blank?
    @city_code = address.try(:city_code) || '430100'
    @district_code = address.try(:code)
  end

  def dashboard
    @dashboard ||= HandymanDashboard.new
  end

  def tabs_info
    [
      {
        text: "技能认证管理",
        path: admin_handyman_certification_index_path
      },
      {
        text: "师傅信息管理",
        path: admin_handyman_account_index_path
      }
    ]
  end

end
