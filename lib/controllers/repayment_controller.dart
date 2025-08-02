import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:staff_loan/models/staff_model.dart';
import '../services/cache_service.dart';

class RepaymentController extends GetxController {
  final CacheService _cacheService = CacheService();

  // Form controllers
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final staffList = <Staff>[].obs;
  final selectedUser = Rxn<Staff>();
  final selectedDate = Rxn<DateTime>();
  final showStaffValidationError = false.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadStaffList();
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load staff list from cache service
  Future<void> loadStaffList() async {
    try {
      isLoading.value = true;
      final response = await _cacheService.getStaffList();
      if (response['success'] == true) {
        final List<dynamic> staffData = response['data'] ?? [];
        staffList.value =
            staffData.map((staff) => Staff.fromJson(staff)).toList();
      }
    } catch (e) {
      print('Error loading staff list: $e');
      Get.snackbar(
        'Error',
        'Failed to load staff list: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Set selected user
  void setSelectedUser(Staff user) {
    selectedUser.value = user;
    showStaffValidationError.value = false; // Clear validation error
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  // Create repayment
  Future<void> createRepayment() async {
    // Reset staff validation error
    showStaffValidationError.value = false;

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedUser.value == null) {
      showStaffValidationError.value = true;
      Get.snackbar(
        'Validation Error',
        'Please select a staff member',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select a date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.red.shade100,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _cacheService.createRepayment(
        valueDate: selectedDate.value!.toIso8601String(),
        description: descriptionController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        transactionType: 'cash_out',
        userId: selectedUser.value!.id,
      );

      // Show success message with transaction ID if available
      final message = response['message'] ?? 'Repayment created successfully';
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: Duration(seconds: 3),
      );

      // Clear form
      clearForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create loan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    amountController.clear();
    descriptionController.clear();
    selectedUser.value = null;
    selectedDate.value = null;
    showStaffValidationError.value = false;
  }

  // Validators
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter loan amount';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }

    if (value.length < 3) {
      return 'Description must be at least 3 characters';
    }

    return null;
  }
}
