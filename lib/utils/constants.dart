class AppConstants {
  // App Information
  static const String appName = 'Natu Staff Loan';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String themeKey = 'isDarkMode';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // API Constants
  static const String baseUrl = 'https://loan.natuworkspace.xyz/api';
  static const String emulatorUrl = 'http://10.0.2.2:8000/api';
  static const String assetUrl = 'https://loan.natuworkspace.xyz';
  static const int timeoutDuration = 30000; // 30 seconds

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String userProfileEndpoint = '/profile/update';
  static const String changePassword = '/profile/change-password';
  static const String profileEndpoint = '/profile';
  static const String usersEndpoint = '/users';
  static const String loansEndpoint = '/loans';
  static const String createLoanEndpoint = '/transactions';
  static const String dashboardEndpoint = '/dashboard';
  static const String historyEndpoint = '/history';
  static const String userDashboardEndpoint = '/user/dashboard';
  static const String userHistoryEndpoint = '/user/history';
  static const String staffList = '/transactions/users';
  static const String staffLoansEndpoint = '/loans';
  static const String createStaffEndpoint = '/register';
  static const String loanStatement = '/loans/statement';
  static const String transactionsEndpoint = '/transactions';
  static const String email = '/loans/send-statement';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Loan Status
  static const String loanStatusPending = 'pending';
  static const String loanStatusApproved = 'approved';
  static const String loanStatusRejected = 'rejected';
  static const String loanStatusActive = 'active';
  static const String loanStatusCompleted = 'completed';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleEmployee = 'employee';
}
