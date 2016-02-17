class HandymanDashboard < AccountDashboard
  RESOURCE_CLASS = "Handyman"

  COLLECTION_ATTRIBUTES = AccountDashboard::COLLECTION_ATTRIBUTES.merge({
  })

  SHOW_PATH_HELPER = "admin_handyman_account_path"
end
