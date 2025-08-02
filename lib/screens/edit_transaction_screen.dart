import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:staff_loan/controllers/edit_transaction_controller.dart';
import 'package:staff_loan/utils/app_colors.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditTransactionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.transaction.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading transaction...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Info Card
              _buildTransactionInfoCard(context, controller),

              const SizedBox(height: 20),

              // Edit Form
              _buildEditForm(context, controller),

              const SizedBox(height: 30),

              // Save Button
              _buildSaveButton(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTransactionInfoCard(
    BuildContext context,
    EditTransactionController controller,
  ) {
    final transaction = controller.transaction.value!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        transaction.isCashIn
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    transaction.isCashIn
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: transaction.isCashIn ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction ID: ${transaction.id}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Staff: ${transaction.user.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Created by: ${transaction.creator.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
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

  Widget _buildEditForm(
    BuildContext context,
    EditTransactionController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Transaction Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryPurple,
          ),
        ),

        const SizedBox(height: 20),

        // Transaction Type Selection
        Text(
          'Transaction Type',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildTypeSelector(
                  context,
                  'Cash In',
                  'cash_in',
                  Icons.trending_up,
                  Colors.green,
                  controller.selectedTransactionType.value == 'cash_in',
                  () => controller.setTransactionType('cash_in'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _buildTypeSelector(
                  context,
                  'Cash Out',
                  'cash_out',
                  Icons.trending_down,
                  Colors.red,
                  controller.selectedTransactionType.value == 'cash_out',
                  () => controller.setTransactionType('cash_out'),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Description Field
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.descriptionController,
          decoration: InputDecoration(
            hintText: 'Enter transaction description',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.description),
          ),
        ),

        const SizedBox(height: 20),

        // Amount Field
        Text(
          'Amount',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.amountController,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.money),
            prefixText: 'N ',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),

        const SizedBox(height: 20),

        // Date Field
        Text(
          'Value Date',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.valueDateController,
          decoration: InputDecoration(
            hintText: 'Select date',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.calendar_today),
            suffixIcon: IconButton(
              onPressed: () => controller.selectDate(context),
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ),
          readOnly: true,
          onTap: () => controller.selectDate(context),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    EditTransactionController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed:
              controller.isSaving.value ? null : controller.updateTransaction,
          icon:
              controller.isSaving.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.save),
          label: Text(controller.isSaving.value ? 'Saving...' : 'Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
