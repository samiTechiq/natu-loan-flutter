import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:staff_loan/services/api_client.dart';
import '../models/staff_loan_model.dart';
import '../services/cache_service.dart';

class StaffsController extends GetxController {
  final CacheService _cacheService = CacheService();

  // Observable variables
  final isLoading = false.obs;
  final staffLoans = <StaffLoan>[].obs;
  final filteredStaffLoans = <StaffLoan>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All Users'.obs;

  // Available filters
  final List<String> filters = ['All Users', 'Active', 'Inactive'];

  @override
  void onInit() {
    super.onInit();
    loadStaffLoans();
  }

  // Load staff loans from API
  Future<void> loadStaffLoans() async {
    try {
      isLoading.value = true;
      final response = await _cacheService.getStaffLoans();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        staffLoans.value =
            data.map((json) => StaffLoan.fromJson(json)).toList();
        _applyFilters();
      } else {
        staffLoans.value = [];
        filteredStaffLoans.value = [];
      }
    } catch (e) {
      debugPrint('Error loading staff loans: $e');
      Get.snackbar(
        'Error',
        'Failed to load staff loans: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    ApiClient().invalidateCache("/loans", 'GET');
    await loadStaffLoans();
  }

  // Search staff by name
  void searchStaff(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  // Apply search and filter
  void _applyFilters() {
    List<StaffLoan> result = staffLoans.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result
              .where(
                (staff) => staff.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
              )
              .toList();
    }

    // Apply status filter (for now, all are considered active)
    // You can modify this logic based on your requirements
    switch (selectedFilter.value) {
      case 'Active':
        result = result.where((staff) => staff.totalOutstanding > 0).toList();
        break;
      case 'Inactive':
        result = result.where((staff) => staff.totalOutstanding == 0).toList();
        break;
      default:
        // All Users - no additional filtering
        break;
    }

    filteredStaffLoans.value = result;
  }

  // Get total outstanding for all staff
  double get totalOutstanding {
    return staffLoans.fold(0.0, (sum, staff) => sum + staff.totalOutstanding);
  }

  // Get staff count by filter
  int get activeStaffCount {
    return staffLoans.where((staff) => staff.totalOutstanding > 0).length;
  }

  int get inactiveStaffCount {
    return staffLoans.where((staff) => staff.totalOutstanding == 0).length;
  }
}
