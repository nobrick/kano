class CertifyDashboard < BaseDashboard
  RESOURCE_CLASS = "Taxon"

  # Hash
  #   key: used to get data and by I18n to traslate (_self_expand 是保留字节, 表示用户扩展的列)
  #   value: 表示数据类型，主要用户数据展现的时候
  #     string: 直接显示
  #     time: 数据需要通过 I18n.l 方法进行翻译
  #     i18n: 数据需要通过 I18n.t 进行翻译
  COLLECTION_ATTRIBUTES = {
    "handyman.id" => :string,
    "_self_expand.handyman_name" => nil,
    "name" => :string,
    "cert_requested_at" => :time,
    "certified_status" => :i18n,
    "certified_at" => :time,
    "certified_by.name" => :string,
    "_self_expand.certify_buttons" => nil
  }

  COLLECTION_FILTER = {
    "certified_status" => { type: :radio, values: { self.value_translate("certified_status", "success")  => "success", self.value_translate("certified_status", "failure") => "failure", self.value_translate("certified_status", "under_review") => "under_review" } },
    "cert_requested_at" => { type: :time_range }
  }

  COLLECTION_FILTER_PATH_HELPER = "admin_handyman_certifications_path"

  SEARCH_PATH_HELPER = "search_admin_handyman_certifications_path"

  SEARCH_PREDICATES = [:handyman_name_cont, :handyman_id_eq]

  EXPAND_PARTIAL_PATH = "admin/handymen/certifications"

  SHOW_PATH_HELPER = "admin_handyman_certification_path"
end
