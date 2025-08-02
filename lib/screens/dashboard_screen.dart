import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_loan/controllers/theme_controller.dart';
import 'package:staff_loan/screens/repayment_screen.dart';
import 'package:staff_loan/utils/constants.dart';
import 'package:staff_loan/utils/format_naira.dart';
import 'package:staff_loan/utils/format_timeago.dart';
import 'package:staff_loan/models/user_model.dart';
import '../controllers/dashboard_controller.dart';
import 'create_loan_screen.dart';
import 'dart:convert';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Method to get user data from local storage
  User? _getUserFromStorage() {
    try {
      final storage = GetStorage();
      final userDataJson = storage.read('user_data');
      if (userDataJson != null) {
        // Check if data is already a Map or if it's a JSON string
        final userData =
            userDataJson is String ? jsonDecode(userDataJson) : userDataJson;
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user data from storage from dashboard screen: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        leading: Obx(
          () => IconButton(
            onPressed:
                () => {
                  if (!dashboardController.isLoading.value)
                    {dashboardController.refreshData()},
                },
            icon:
                dashboardController.isLoading.value
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.refresh),
          ),
        ),
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) {
              final user = _getUserFromStorage();
              return CircleAvatar(
                radius: 20,
                backgroundImage:
                    user?.image != null && user!.image!.isNotEmpty
                        ? CachedNetworkImageProvider(
                          "${AppConstants.assetUrl}${user.image}",
                        )
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Builder(
              builder: (context) {
                final user = _getUserFromStorage();
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors:
                          Theme.of(context).brightness == Brightness.light
                              ? [
                                AppColors.darkPurple.withValues(alpha: 1.0),
                                AppColors.lightPurple.withValues(alpha: 0.9),
                                AppColors.primaryPurple.withValues(alpha: 0.9),
                              ]
                              : [
                                AppColors.primaryPurple.withValues(alpha: 0.1),
                                AppColors.primaryPurple.withValues(alpha: 0.2),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.name.split(" ")[0] ?? 'User'}!',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here\'s an overview of your loan management dashboard.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Quick Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildStatCard(
                      context,
                      'Total Cash Out',
                      formatNaira(dashboardController.totalCashOut.value),
                      Icons.remove,
                      Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => _buildStatCard(
                      context,
                      'Total Cash In',
                      formatNaira(dashboardController.totalCashIn.value),
                      Icons.add,
                      Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildStatCard(
                      context,
                      'Net Balance',
                      formatNaira(dashboardController.netBalance.value),
                      Icons.account_balance_wallet,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => _buildStatCard(
                      context,
                      'Total Users',
                      dashboardController.totalUsers.value.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const CreateLoanScreen());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Loan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => const RepaymentScreen());
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text('Repay Loan'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Obx(() {
                  if (dashboardController.recentTransactions.isEmpty) {
                    return const Center(child: Text('No recent activity'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboardController.recentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction =
                          dashboardController.recentTransactions[index];
                      return ListTile(
                        leading:
                            transaction.transactionType == 'cash_in'
                                ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                )
                                : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                        title: Text(
                          transaction.user?.name ?? 'Unknown User',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          formatNaira(transaction.amount),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          formatTimeAgo(transaction.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Icon(icon, color: color, size: 24)),
                ),
                Text(
                  value.toString(),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
