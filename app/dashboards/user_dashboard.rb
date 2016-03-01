class UserDashboard < AccountDashboard
  RESOURCE_CLASS = "User"

  COLLECTION_ATTRIBUTES = AccountDashboard::COLLECTION_ATTRIBUTES.merge({
  })

  SHOW_PATH_HELPER = "admin_user_account_path"
end
