import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_loan/controllers/user_dashboard_controller.dart';
import 'package:staff_loan/utils/app_colors.dart';
import 'package:staff_loan/utils/constants.dart';
import 'package:staff_loan/utils/format_naira.dart';
import 'package:staff_loan/models/user_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  // Observable for tracking storage changes
  static final _storageData = Rx<User?>(null);

  // Method to get user data from local storage with reactivity
  User? _getUserFromStorage() {
    try {
      final storage = GetStorage();
      final userDataJson = storage.read('user_data');
      if (userDataJson != null) {
        // Check if data is already a Map or if it's a JSON string
        final userData =
            userDataJson is String ? jsonDecode(userDataJson) : userDataJson;
        final user = User.fromJson(userData);
        _storageData.value = user; // Update observable
        return user;
      } else {
        debugPrint('No user data found in storage');
      }
    } catch (e) {
      debugPrint(
        'Error loading user data from storage from user dashboard screen: $e',
      );
    }
    _storageData.value = null;
    return null;
  }

  // Static method to refresh user data from other screens
  static void refreshUserData() {
    try {
      final storage = GetStorage();
      final userDataJson = storage.read('user_data');
      if (userDataJson != null) {
        // Check if data is already a Map or if it's a JSON string
        final userData =
            userDataJson is String ? jsonDecode(userDataJson) : userDataJson;
        final user = User.fromJson(userData);
        _storageData.value = user;

        debugPrint('Refreshed user object: ${user.toJson()}');
      } else {
        _storageData.value = null;
        debugPrint('No data to refresh');
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
      _storageData.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserDashboardController());

    // Initialize user data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_storageData.value == null) {
        _getUserFromStorage();
      }
    });

    // Then in build method:
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );
    return Scaffold(
      body: Column(
        children: [
          // Simple App Bar with User Info
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple,
                  AppColors.primaryPurple,
                  AppColors.primaryPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    // User Avatar
                    Obx(() {
                      _getUserFromStorage(); // Trigger refresh
                      final user = _storageData.value;
                      return Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              user?.image != null && user!.image!.isNotEmpty
                                  ? CachedNetworkImage(
                                    imageUrl:
                                        "${AppConstants.assetUrl}${user.image!}",
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      size: 20,
                                    ),
                                  ),
                        ),
                      );
                    }),

                    const SizedBox(width: 12),

                    // Greeting and Name
                    Expanded(
                      child: Obx(() {
                        _getUserFromStorage(); // Trigger refresh
                        final user = _storageData.value;
                        final firstName = user?.name.split(' ').first ?? 'User';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              firstName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }),
                    ),

                    // Refresh Button
                    Obx(
                      () => IconButton(
                        onPressed: () => controller.refreshData(),
                        icon:
                            controller.isLoading.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.dashboardData.value == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading dashboard...'),
                        ],
                      ),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty &&
                      controller.dashboardData.value == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load dashboard',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.refreshData(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = controller.dashboardData.value;
                  if (data == null) {
                    return const Center(child: Text('No data available'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Overview Cards
                      _buildBalanceOverview(context, controller, data),

                      const SizedBox(height: 24),

                      // Statistics Row
                      _buildStatisticsRow(context, data),

                      const SizedBox(height: 24),

                      // Recent Transactions
                      _buildRecentTransactions(context, data),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildBalanceOverview(
    BuildContext context,
    UserDashboardController controller,
    data,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.darkPurple.withValues(alpha: 1.0),
              AppColors.lightPurple.withValues(alpha: 0.9),
              AppColors.primaryPurple.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Icon(
                  controller.getBalanceTrendIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formatNaira(data.netBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Loan Issued',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        formatNaira(data.totalCashIn),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Repaid',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        formatNaira(data.totalCashOut),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(BuildContext context, data) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Transactions',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.recordCount}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.trending_up, color: Colors.green[600], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Active Status',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.recordCount > 0 ? 'Active' : 'Inactive',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          data.recordCount > 0
                              ? Colors.green[600]
                              : Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (data.recentTransactions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No recent transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transaction history will appear here',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...data.recentTransactions
              .take(5)
              .map(
                (transaction) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          transaction.isCashIn
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                      child: Icon(
                        transaction.isCashIn ? Icons.add : Icons.remove,
                        color: transaction.isCashIn ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      transaction.description,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'MMM dd, yyyy',
                      ).format(DateTime.parse(transaction.valueDate)),
                    ),
                    trailing: Text(
                      '${transaction.isCashIn ? '+' : '-'}${formatNaira(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction.isCashIn ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
      ],
    );
  }
}
