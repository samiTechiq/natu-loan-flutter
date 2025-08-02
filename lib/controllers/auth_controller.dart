import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/utils/constants.dart';
import '../models/user_model.dart';
import '../services/data_service.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final _dataService = DataService();

  // Observable variables
  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs; // Storage keys
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  // Load user data from storage on app start
  void _loadUserFromStorage() {
    try {
      final userData = _storage.read(_userKey);
      final token = _storage.read(_tokenKey);
      final loggedIn = _storage.read(_isLoggedInKey) ?? false;

      if (userData != null && token != null && loggedIn) {
        currentUser.value = User.fromJson(userData);
        isLoggedIn.value = true;
      } else {
        debugPrint('No valid user data found in storage');
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
      _clearStorage();
    }
  }

  // Login with real API call
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Make API call using DataService
      final responseData = await _dataService.login(email, password);

      // Handle response
      if (responseData['success'] == true) {
        return await _handleLoginSuccess(responseData);
      } else {
        Get.snackbar(
          'Login Failed',
          responseData['message'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: Icon(Icons.error, color: Colors.red.shade900),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Handle successful login response
  Future<bool> _handleLoginSuccess(Map<String, dynamic> responseData) async {
    try {
      if (responseData['success'] == true) {
        // Create user object
        final user = User.fromJson(responseData['user']);
        final token = responseData['token'];

        // Store data
        await _storage.write(_userKey, responseData['user']);
        await _storage.write(_tokenKey, token);
        await _storage.write(_isLoggedInKey, true);

        // Update observables
        currentUser.value = user;
        isLoggedIn.value = true;

        Get.snackbar(
          'Success',
          responseData['message'] ?? 'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          icon: Icon(Icons.check_circle, color: Colors.green.shade900),
        );

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error handling login success: $e');
      return false;
    }
  }

  // Logout user with API call
  Future<void> logout() async {
    try {
      // Clear local storage
      await _clearStorage();
      currentUser.value = null;
      isLoggedIn.value = false;
      ApiClient().clearCache();

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      await _clearStorage();
      currentUser.value = null;
      isLoggedIn.value = false;
    }
  }

  // Clear storage
  Future<void> _clearStorage() async {
    await _storage.remove(_userKey);
    await _storage.remove(_tokenKey);
    await _storage.remove(_isLoggedInKey);
  }

  // Get stored token
  String? get token => _storage.read(_tokenKey);

  // Get user profile from API
  Future<void> getUserProfile() async {
    try {
      final responseData = await _dataService.getUserProfile();

      if (responseData['success'] == true) {
        final user = User.fromJson(responseData['user']);
        currentUser.value = user;
        // Update stored user data
        await _storage.write(_userKey, responseData['user']);
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (isLoggedIn.value) {
      ApiClient().invalidateCache(AppConstants.userProfileEndpoint, "GET");
      await getUserProfile();
    }
  }

  // Validate email
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
