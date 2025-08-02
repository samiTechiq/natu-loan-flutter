import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_loan/models/staff_model.dart';
import '../controllers/loan_controller.dart';
import '../controllers/theme_controller.dart';
import 'searchable_staff_selection_screen.dart';

class CreateLoanScreen extends StatelessWidget {
  const CreateLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loanController = Get.put(LoanController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Loan'),
        elevation: 0,
        centerTitle: false,
        actions: [
          // refresh staff list
          Obx(
            () => IconButton(
              onPressed:
                  loanController.isLoading.value
                      ? null
                      : () => loanController.refreshStaffList(),
              icon:
                  loanController.isLoading.value
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
      body: Obx(() {
        // Show loading only on initial load when no staff data is available
        if (loanController.isLoading.value &&
            loanController.staffList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading staff members...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: loanController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                const SizedBox(height: 24),

                // Staff Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Staff Member',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Obx(() {
                          if (loanController.isLoading.value &&
                              loanController.staffList.isEmpty) {
                            return Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.purple,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Loading staff...'),
                                  ],
                                ),
                              ),
                            );
                          }

                          return _buildStaffSelector(context, loanController);
                        }),
                        const SizedBox(height: 8),
                        // Show validation error if no staff is selected
                        Obx(() {
                          if (loanController.showStaffValidationError.value) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                'Please select a staff member',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Loan Details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loan Details',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Amount Field
                        TextFormField(
                          controller: loanController.amountController,
                          decoration: InputDecoration(
                            labelText: 'Loan Amount *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: loanController.validateAmount,
                        ),

                        const SizedBox(height: 16),

                        // Description Field
                        TextFormField(
                          controller: loanController.descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          maxLines: 1,
                          validator: loanController.validateDescription,
                        ),

                        const SizedBox(height: 16),

                        // Date Field
                        Obx(
                          () => InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    loanController.selectedDate.value ??
                                    DateTime.now(),
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 30),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                loanController.setSelectedDate(date);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Value Date *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                loanController.selectedDate.value != null
                                    ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(loanController.selectedDate.value!)
                                    : 'Select Date',
                                style: TextStyle(
                                  color:
                                      loanController.selectedDate.value != null
                                          ? null
                                          : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            loanController.isLoading.value
                                ? null
                                : () {
                                  loanController.clearForm();
                                  Get.back();
                                },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed:
                              loanController.isLoading.value
                                  ? null
                                  : loanController.createLoan,
                          child:
                              loanController.isLoading.value
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Create Loan'),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStaffSelector(
    BuildContext context,
    LoanController loanController,
  ) {
    return Obx(
      () => InkWell(
        onTap:
            loanController.staffList.isEmpty
                ? null
                : () async {
                  final selectedStaff = await Get.to<Staff>(
                    () => SearchableStaffSelectionScreen(
                      staffList: loanController.staffList,
                      selectedStaff: loanController.selectedUser.value,
                    ),
                  );
                  if (selectedStaff != null) {
                    loanController.setSelectedUser(selectedStaff);
                  }
                },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Staff Member *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.person),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          child: Row(
            children: [
              if (loanController.selectedUser.value != null) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryPurple,
                  child: Text(
                    loanController.selectedUser.value!.name
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loanController.selectedUser.value!.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    loanController.staffList.isEmpty
                        ? 'No staff available'
                        : 'Select staff member',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
