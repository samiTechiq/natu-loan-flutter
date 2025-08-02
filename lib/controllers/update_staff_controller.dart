import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_loan/services/staff_service.dart';
import '../controllers/staffs_controller.dart';
import 'dart:io';
import 'dart:convert';

class UpdateStaffController extends GetxController {
  final StaffService _staffService = StaffService();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString currentImageUrl = ''.obs;

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Staff data
  int? staffId;

  // Initialize with staff data
  void initializeStaffData({
    required int id,
    required String name,
    required String email,
    required String phone,
    String? imageUrl,
  }) {
    staffId = id;
    nameController.text = name;
    emailController.text = email;
    phoneController.text = phone;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      currentImageUrl.value = imageUrl;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeImage() {
    selectedImage.value = null;
    currentImageUrl.value = '';
  }

  Future<void> updateStaff() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (staffId == null) {
      Get.snackbar(
        'Error',
        'Staff ID is missing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      Map<String, dynamic> staffData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      // Only include password if it's been changed
      if (passwordController.text.isNotEmpty) {
        staffData['password'] = passwordController.text;
      }

      await _staffService.update(
        staffId!,
        jsonEncode(staffData),
        fileUrl: selectedImage.value?.path,
      );

      Get.snackbar(
        'Success',
        'Staff updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      // Try to refresh the staffs list if it exists
      try {
        Get.find<StaffsController>().refreshData();
      } catch (e) {
        throw Exception('Failed to refresh staff list: ${e.toString()}');
      }
    } catch (e) {
      debugPrint(e.toString());
      // Try to parse error messages
      String errorMessage = 'Failed to update staff ${e.toString()}';

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    // Password is optional when updating - if empty, keep existing password
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
