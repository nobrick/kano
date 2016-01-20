class UserDashboard < AccountDashboard
  RESOURCE_CLASS = "User"

  ATTRIBUTE_TYPES = AccountDashboard::ATTRIBUTE_TYPES.merge({
  })

  PATH_HELPER = nil
end
