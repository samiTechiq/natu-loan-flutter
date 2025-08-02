import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/models/user_dashboard_model.dart';
import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/services/cache_service.dart';
import 'package:staff_loan/utils/constants.dart';

class UserDashboardController extends GetxController {
  final CacheService _cacheService = CacheService();

  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var dashboardData = Rxn<UserDashboardData>();

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _cacheService.getUserDashboardData();

      if (response['success'] == true && response['data'] != null) {
        dashboardData.value = UserDashboardData.fromJson(response['data']);
      } else {
        throw response['message'] ?? 'Failed to load dashboard data';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load dashboard: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    ApiClient().invalidateCache(AppConstants.userDashboardEndpoint, 'GET');
    await loadDashboardData();
  }

  // Calculate balance trend
  String getBalanceTrend() {
    final data = dashboardData.value;
    if (data == null) return '';

    if (data.netBalance > 0) {
      return 'positive';
    } else if (data.netBalance < 0) {
      return 'negative';
    } else {
      return 'neutral';
    }
  }

  // Get balance trend color
  Color getBalanceTrendColor() {
    switch (getBalanceTrend()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get balance trend icon
  IconData getBalanceTrendIcon() {
    switch (getBalanceTrend()) {
      case 'positive':
        return Icons.trending_up;
      case 'negative':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}
