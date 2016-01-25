class ManagerDashboard < AccountDashboard
  RESOURCE_CLASS = "Account"

  ATTRIBUTE_TYPES = AccountDashboard::ATTRIBUTE_TYPES.merge({
  })

  PATH_HELPER = nil
end
