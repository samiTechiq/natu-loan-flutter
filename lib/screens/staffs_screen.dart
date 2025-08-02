import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:staff_loan/utils/constants.dart';
import 'package:staff_loan/utils/format_naira.dart';
import '../controllers/staffs_controller.dart';
import '../screens/create_staff_screen.dart';
import '../screens/update_staff_screen.dart';
import '../screens/loan_statement_screen.dart';
import '../utils/app_colors.dart';

class StaffsScreen extends StatelessWidget {
  const StaffsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staffsController = Get.put(StaffsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staffs Loans'),
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          Obx(
            () => IconButton(
              onPressed:
                  staffsController.isLoading.value
                      ? null
                      : () => staffsController.refreshData(),
              icon:
                  staffsController.isLoading.value
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CreateStaffScreen()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (staffsController.isLoading.value &&
            staffsController.staffLoans.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading staff loans...'),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 50.0),
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search staff...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: staffsController.searchStaff,
              ),

              const SizedBox(height: 24),

              // Staff List
              Expanded(
                child: Obx(() {
                  if (staffsController.staffLoans.isEmpty &&
                      !staffsController.isLoading.value) {
                    return _buildEmptyState(context);
                  }

                  if (staffsController.filteredStaffLoans.isEmpty) {
                    return _buildNoResultsState(context);
                  }

                  return RefreshIndicator(
                    onRefresh: staffsController.refreshData,
                    child: ListView.builder(
                      itemCount: staffsController.filteredStaffLoans.length,
                      itemBuilder: (context, index) {
                        final staff =
                            staffsController.filteredStaffLoans[index];
                        return _buildStaffCard(context, staff);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStaffCard(BuildContext context, staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade50, width: 0.5),
        ),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(0.0),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryPurple,
          backgroundImage:
              staff.image != null
                  ? CachedNetworkImageProvider(
                    '${AppConstants.assetUrl}/storage/${staff.image}',
                  )
                  : null,
          child:
              staff.image == null
                  ? Text(
                    staff.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        title: Text(
          staff.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          "Outstanding: ${formatNaira(staff.totalOutstanding)}",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
        ),
        onTap: () {
          _showStaffDetailsBottomSheet(context, staff);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Staff Found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Staff loan data will appear here once available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Get.find<StaffsController>().refreshData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showStaffDetailsBottomSheet(BuildContext context, staff) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Staff Avatar and Basic Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryPurple,
                      backgroundImage:
                          staff.image != null && staff.image.isNotEmpty
                              ? CachedNetworkImageProvider(
                                '${AppConstants.assetUrl}/storage/${staff.image}',
                              )
                              : null,
                      child:
                          staff.image == null || staff.image.isEmpty
                              ? Text(
                                staff.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  staff.totalOutstanding > 0
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.totalOutstanding > 0
                                  ? 'Active Loan'
                                  : 'No Outstanding',
                              style: TextStyle(
                                color:
                                    staff.totalOutstanding > 0
                                        ? Colors.red[700]
                                        : Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Contact Information
                _buildDetailSection(context, 'Contact Information', [
                  _buildCopyableDetailRow(
                    context,
                    Icons.email,
                    'Email',
                    staff.email,
                  ),
                  _buildCopyableDetailRow(
                    context,
                    Icons.phone,
                    'Phone',
                    staff.phone.toString(),
                  ),
                ]),

                const SizedBox(height: 20),

                // Loan Information
                _buildDetailSection(context, 'Loan Information', [
                  _buildDetailRow(
                    Icons.account_balance_wallet,
                    'Total Outstanding',
                    formatNaira(staff.totalOutstanding),
                    valueColor:
                        staff.totalOutstanding > 0
                            ? Colors.red[600]
                            : Colors.green[600],
                  ),
                  _buildDetailRow(
                    Icons.date_range,
                    'Member Since',
                    _formatDate(staff.createdAt),
                  ),
                ]),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Get.to(
                            () => UpdateStaffScreen(
                              staffId: staff.id,
                              staffName: staff.name,
                              staffEmail: staff.email,
                              staffPhone: staff.phone.toString(),
                              staffImageUrl: staff.image,
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Staff'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryPurple,
                          ),
                          foregroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to loan statement screen
                          Get.to(
                            () => const LoanStatementScreen(),
                            arguments: {
                              'staffId': staff.id.toString(),
                              'staffName': staff.name,
                              'staffEmail': staff.email,
                            },
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('View Loans'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryPurple.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryPurple.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _copyToClipboard(context, value, label),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: valueColor ?? AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.copy,
                      size: 16,
                      color: AppColors.primaryPurple.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar(
      'Copied!',
      '$label copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
