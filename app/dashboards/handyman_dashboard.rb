class HandymanDashboard < AdminScaffold::AccountDashboard
  RESOURCE_CLASS = "Handyman"

  COLLECTION_ATTRIBUTES = AccountDashboard::COLLECTION_ATTRIBUTES.merge({
  })

  SEARCH_PATH_HELPER = "admin_handyman_accounts_path"

  SEARCH_PREDICATES = [:name_or_email_cont, :id_or_phone_eq]

  SHOW_PATH_HELPER = "admin_handyman_account_path"
end
