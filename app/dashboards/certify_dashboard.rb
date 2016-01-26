class CertifyDashboard < BaseDashboard
  RESOURCE_CLASS = "Taxon"

  # Hash
  #   key: used to get data and by I18n to traslate (_self_expand 是保留字节, 表示用户扩展的列)
  #   value: 表示数据类型，主要用户数据展现的时候
  #     string: 直接显示
  #     time: 数据需要通过 I18n.l 方法进行翻译
  #     i18n: 数据需要通过 I18n.t 进行翻译

  ATTRIBUTE_TYPES = {
    "_self_expand.all_selected" => nil,
    "handyman.id" => :string,
    "handyman.name" => :string,
    "name" => :string,
    "cert_requested_at" => :time,
    "certified_status" => :i18n ,
    "_self_expand.certify_buttons" => nil
  }

  FILTER = {
    "attr" => "certified_status",
    "status" => %w(success failure under_review),
    "baseurl" => "admin_handyman_certifications_path"
  }

  TEMPLATE_PATH = "admin/handymen/certifications"

  PATH_HELPER = "admin_handyman_certification_path"
end
