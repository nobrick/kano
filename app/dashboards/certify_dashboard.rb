class CertifyDashboard < AdminScaffold::BaseDashboard

  attributes("Taxon") do |d|
    d.string "handyman.id", owner: "Handyman", methods: "handyman.id"
    d.expand "handyman.name", owner: "Handyman", partial_path: "admin/handymen/certifications", header: "管家姓名"
    d.string "name"
    d.date_time "cert_requested_at"
    d.string "certified_status", i18n: true, styles: { "success" => :success, "failure" => :danger, "under_review" => :warning }
    d.date_time "certified_at"
    d.string "certified_by.name", owner: "Admin", methods: "certified_by.name"
    d.expand "certify_buttons", partial_path: "admin/handymen/certifications"
  end

  filters("admin_handyman_certifications_path") do |f|
    f.eq "certified_status", display: :radio, values: ["success", "failure", "under_review"]
    f.time_range "cert_requested_at"
  end

  search("search_admin_handyman_certifications_path") do |s|
    s.cont "handyman.name"
    s.eq   "handyman.id"
  end
end
