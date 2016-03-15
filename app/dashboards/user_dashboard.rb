class UserDashboard < AccountDashboard
  RESOURCE_CLASS = "User"

  COLLECTION_ATTRIBUTES = AccountDashboard::COLLECTION_ATTRIBUTES.merge({
  })

  SEARCH_PATH_HELPER = "admin_user_accounts_path"

  SEARCH_PREDICATES = [:name_or_email_cont, :id_or_phone_eq]

  SHOW_PATH_HELPER = "admin_user_account_path"
end
