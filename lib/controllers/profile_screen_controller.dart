import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_loan/models/user_model.dart';
import 'package:staff_loan/services/data_service.dart';

class ProfileScreenController extends GetxController {
  final DataService _dataService = DataService();
  final _storage = GetStorage();

  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _dataService.getUserProfile();

      if (response['success'] == true && response['data'] != null) {
        final userData = response['data']['user'];

        user.value = User.fromJson(userData);
        await _storage.write('user_data', jsonEncode(user.value!.toJson()));
      } else {
        throw response['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      await loadUserProfile();
      Get.snackbar(
        'Success',
        'Profile refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
