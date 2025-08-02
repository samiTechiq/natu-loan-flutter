import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/controllers/auth_controller.dart';
import 'package:staff_loan/screens/login_screen.dart';
import 'package:staff_loan/services/data_service.dart';

class ChangePasswordController extends GetxController {
  final DataService _dataService = DataService();
  final AuthController authController = Get.find<AuthController>();

  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Form controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Password visibility toggles
  var showCurrentPassword = false.obs;
  var showNewPassword = false.obs;
  var showConfirmPassword = false.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    showCurrentPassword.value = !showCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    showNewPassword.value = !showNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _dataService.changePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Clear form and go back
      _clearForm();
      authController.logout(); // Log out user after password change
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (currentPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (newPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (newPasswordController.text.trim().length < 8) {
      Get.snackbar(
        'Validation Error',
        'New password must be at least 8 characters long',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please confirm your new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Get.snackbar(
        'Validation Error',
        'New passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (currentPasswordController.text.trim() ==
        newPasswordController.text.trim()) {
      Get.snackbar(
        'Validation Error',
        'New password must be different from current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void _clearForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    showCurrentPassword.value = false;
    showNewPassword.value = false;
    showConfirmPassword.value = false;
    errorMessage.value = '';
  }

  void resetForm() {
    _clearForm();
  }
}
