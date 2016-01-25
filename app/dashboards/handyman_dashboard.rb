class HandymanDashboard < AccountDashboard
  RESOURCE_CLASS = "Handyman"

  COLLECTION_ATTRIBUTES = AccountDashboard::COLLECTION_ATTRIBUTES.merge({
  })
end
