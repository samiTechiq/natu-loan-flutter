import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/models/transaction_model.dart';
import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/services/cache_service.dart';
import 'package:staff_loan/utils/constants.dart';

class EditTransactionController extends GetxController {
  final CacheService _cacheService = CacheService();

  // Observable variables
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  // Form controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController valueDateController = TextEditingController();

  // Transaction data
  var transaction = Rxn<Transaction>();
  var selectedTransactionType = 'cash_in'.obs;
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();

    // Get transaction data directly from arguments
    final transactionArg = Get.arguments;
    if (transactionArg != null && transactionArg is Transaction) {
      transaction.value = transactionArg;
      _initializeFormData();
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    valueDateController.dispose();
    super.onClose();
  }

  void _initializeFormData() {
    if (transaction.value != null) {
      final trans = transaction.value!;

      descriptionController.text = trans.description;
      amountController.text = trans.amount.toString();
      selectedTransactionType.value = trans.transactionType;

      try {
        selectedDate.value = DateTime.parse(trans.valueDate);
        valueDateController.text = _formatDate(selectedDate.value);
      } catch (e) {
        selectedDate.value = DateTime.now();
        valueDateController.text = _formatDate(selectedDate.value);
      }
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF6B46C1), // AppColors.primaryPurple
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      valueDateController.text = _formatDate(picked);
    }
  }

  void setTransactionType(String type) {
    selectedTransactionType.value = type;
  }

  Future<void> updateTransaction() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;
      errorMessage.value = '';

      await _cacheService.updateTransaction(
        transactionId: transaction.value!.id,
        valueDate: _formatDateForApi(selectedDate.value),
        description: descriptionController.text.trim(),
        amount: double.parse(amountController.text),
        transactionType: selectedTransactionType.value,
      );

      ApiClient().invalidateCache(AppConstants.transactionsEndpoint, 'GET');

      Get.snackbar(
        'Success',
        'Transaction updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: Icon(Icons.check_circle, color: Colors.green.shade900),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update transaction: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: Icon(Icons.error, color: Colors.red.shade900),
      );
    } finally {
      isSaving.value = false;
    }
  }

  bool _validateForm() {
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (amountController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter an amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get transactionTypeName {
    return selectedTransactionType.value == 'cash_in' ? 'Cash In' : 'Cash Out';
  }

  bool get isCashIn {
    return selectedTransactionType.value == 'cash_in';
  }
}
