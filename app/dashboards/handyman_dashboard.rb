class HandymanDashboard < AdminScaffold::BaseDashboard

  attributes("Handyman") do |d|
    d.string "id"
    d.string "name"
    d.string "nickname"
    d.string "phone"
    d.string "email"
    d.date_time "created_at"
    d.date_time "last_sign_in_at"
  end

  search("admin_handyman_accounts_path") do |s|
    s.cont "name"
    s.cont "email"
    s.eq   "id"
    s.eq   "phone"
  end

  show_page "admin_handyman_account_path"
end
