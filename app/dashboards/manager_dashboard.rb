class ManagerDashboard < AccountDashboard
  RESOURCE_CLASS = "Account"

  COLLECTION_ATTRIBUTES = AccountDashboard::COLLECTION_ATTRIBUTES.merge({
  })
end
