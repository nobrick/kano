class HandymanDashboard < AccountDashboard
  RESOURCE_CLASS = "Handyman"

  ATTRIBUTE_TYPES = AccountDashboard::ATTRIBUTE_TYPES.merge({
  })


  PATH_HELPER = nil
end
