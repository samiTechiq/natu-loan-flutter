import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/controllers/user_dashboard_controller.dart';
import 'package:staff_loan/controllers/auth_controller.dart';
import 'package:staff_loan/utils/app_colors.dart';
import 'package:staff_loan/utils/format_naira.dart';
import 'package:intl/intl.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserDashboardController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Column(
        children: [
          // Custom App Bar with User Info
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkPurple,
                  AppColors.primaryPurple,
                  AppColors.lightPurple.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Top Row with greeting and refresh
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Greeting and user info
                        Expanded(
                          child: Row(
                            children: [
                              // User Avatar
                              Obx(() {
                                final user = authController.currentUser.value;
                                return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child:
                                        user?.image != null &&
                                                user!.image!.isNotEmpty
                                            ? Image.network(
                                              user.image!.startsWith('http')
                                                  ? user.image!
                                                  : 'https://your-domain.com/storage/${user.image}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.2),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.8),
                                                    size: 24,
                                                  ),
                                                );
                                              },
                                            )
                                            : Container(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                                size: 24,
                                              ),
                                            ),
                                  ),
                                );
                              }),

                              const SizedBox(width: 16),

                              // Greeting Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Obx(() {
                                      final user =
                                          authController.currentUser.value;
                                      return Text(
                                        user?.name ?? 'User',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Refresh Button
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (controller.dashboardData.value != null) {
                                  controller.refreshData();
                                }
                              },
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
                                        size: 22,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dashboard Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.dashboard_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'My Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
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
      elevation: 4,
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
