import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/models/user_dashboard_model.dart';
import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/services/cache_service.dart';
import 'package:staff_loan/utils/constants.dart';

class UserHistoryController extends GetxController {
  final CacheService _cacheService = CacheService();

  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var historyData = Rxn<UserHistoryData>();
  var selectedFilter = 'all'.obs;

  // Filter options
  final List<String> filterOptions = ['all', 'cash_in', 'cash_out'];

  @override
  void onInit() {
    super.onInit();
    loadHistoryData();
  }

  Future<void> loadHistoryData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _cacheService.getUserHistory();

      if (response['success'] == true) {
        historyData.value = UserHistoryData.fromJson(response);
      } else {
        throw response['message'] ?? 'Failed to load history data';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load history: ${e.toString()}',
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
    ApiClient().invalidateCache(AppConstants.userHistoryEndpoint, "GET");
    await loadHistoryData();
  }

  // Get filtered history entries
  List<UserHistoryEntry> get filteredEntries {
    final data = historyData.value;
    if (data == null) return [];

    switch (selectedFilter.value) {
      case 'cash_in':
        return data.entries.where((entry) => entry.isCashIn).toList();
      case 'cash_out':
        return data.entries.where((entry) => entry.isCashOut).toList();
      default:
        return data.entries;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  String getFilterDisplayName(String filter) {
    switch (filter) {
      case 'cash_in':
        return 'Cash In';
      case 'cash_out':
        return 'Cash Out';
      default:
        return 'All';
    }
  }

  // Get transaction type color
  Color getTransactionColor(UserHistoryEntry entry) {
    return entry.isCashIn ? Colors.green : Colors.red;
  }

  // Get transaction icon
  IconData getTransactionIcon(UserHistoryEntry entry) {
    return entry.isCashIn ? Icons.add_circle : Icons.remove_circle;
  }

  // Format balance display
  String formatBalance(double balance) {
    if (balance >= 0) {
      return '+${balance.toStringAsFixed(2)}';
    } else {
      return balance.toStringAsFixed(2);
    }
  }
}
