class ManagerDashboard < AdminScaffold::AccountDashboard
  RESOURCE_CLASS = "User"

  COLLECTION_ATTRIBUTES = AccountDashboard::COLLECTION_ATTRIBUTES.merge({
  })
end
