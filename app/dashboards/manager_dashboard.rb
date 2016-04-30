class ManagerDashboard < AccountDashboard

  attributes("User") do |d|
    d.string "id"
    d.string "name"
    d.string "nickname"
    d.string "phone"
    d.string "email"
    d.date_time "created_at"
    d.date_time "last_sign_in_at"
  end
end
