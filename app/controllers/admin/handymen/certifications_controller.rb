class Admin::Handymen::CertificationsController < Admin::ApplicationController

  def index
    @taxons = Taxon.all
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
end
