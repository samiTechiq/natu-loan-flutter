class RoleHelper {
  // Define role constants
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String userRole = 'user';
  static const String employeeRole = 'employee';

  // Check if user is admin or manager (has admin privileges)
  static bool isAdmin(String? role) {
    if (role == null) return false;
    return role.toLowerCase() == adminRole || role.toLowerCase() == managerRole;
  }

  // Check if user is regular user or employee
  static bool isUser(String? role) {
    if (role == null) return false;
    return role.toLowerCase() == userRole || role.toLowerCase() == employeeRole;
  }

  // Get user role display name
  static String getRoleDisplayName(String? role) {
    if (role == null) return 'Unknown';

    switch (role.toLowerCase()) {
      case adminRole:
        return 'Administrator';
      case managerRole:
        return 'Manager';
      case userRole:
        return 'User';
      case employeeRole:
        return 'Employee';
      default:
        return role.toUpperCase();
    }
  }

  // Check if user can perform admin actions
  static bool canManageStaff(String? role) {
    return isAdmin(role);
  }

  // Check if user can edit transactions
  static bool canEditTransactions(String? role) {
    return isAdmin(role);
  }

  // Check if user can create loans for others
  static bool canCreateLoansForOthers(String? role) {
    return isAdmin(role);
  }

  // Check if user can view all transactions
  static bool canViewAllTransactions(String? role) {
    return isAdmin(role);
  }
}
