import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_loan/models/user_model.dart';
import 'package:staff_loan/controllers/auth_controller.dart';
import 'package:staff_loan/services/staff_service.dart';
import 'package:staff_loan/screens/user_dashboard_screen.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final StaffService _staffService = StaffService();
  final _storage = GetStorage();

  // Observable variables
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Profile image
  var selectedImage = Rxn<File>();
  var imageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFormData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _initializeFormData() {
    try {
      // Get user data from storage
      final userDataJson = _storage.read('user_data');
      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson);
        final user = User.fromJson(userData);

        nameController.text = user.name;
        emailController.text = user.email;
        phoneController.text = user.phone ?? '';
        imageUrl.value = user.image ?? '';
      }
    } catch (e) {
      print('Error loading user data from storage: $e');
      // Fallback to auth controller if storage fails
      final user = _authController.currentUser.value;
      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        phoneController.text = user.phone ?? '';
        imageUrl.value = user.image ?? '';
      }
    }
  }

  Future<void> selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show bottom sheet to choose image source
      final source = await Get.bottomSheet<ImageSource>(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Image Source',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Camera'),
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Gallery'),
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Cancel'),
                  onTap: () => Get.back(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        isDismissible: true,
      );

      if (source != null) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          selectedImage.value = File(pickedFile.path);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
  }

  Future<void> updateProfile() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;
      errorMessage.value = '';

      Map<String, dynamic> userData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      final profileResponse = await _staffService.updateProfile(
        jsonEncode(userData),
        fileUrl: selectedImage.value?.path,
      );

      try {
        if (profileResponse['success'] == true &&
            profileResponse['data'] != null) {
          final userData = profileResponse['data']['user'];
          final updatedUser = User.fromJson(userData);
          await _storage.write('user_data', jsonEncode(updatedUser.toJson()));

          // Debug: Print profile update storage
          print('=== PROFILE CONTROLLER UPDATE ===');
          print('Profile response data: ${profileResponse['data']}');
          print('Updated user object: ${updatedUser.toJson()}');
          print('Stored JSON: ${jsonEncode(updatedUser.toJson())}');

          // Refresh user dashboard data
          UserDashboardScreen.refreshUserData();
        }
      } catch (e) {
        // If profile fetch fails, still show success for update
        print('Warning: Profile update succeeded but failed to refresh: $e');
      }
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isSaving.value = false;
    }
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void resetForm() {
    selectedImage.value = null;
    errorMessage.value = '';
    _initializeFormData();
  }
}
