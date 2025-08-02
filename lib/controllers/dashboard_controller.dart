import 'package:get/get.dart';
import 'package:staff_loan/models/dashboard_model.dart';
import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/services/cache_service.dart';

class DashboardController extends GetxController {
  final _cacheService = CacheService();

  // Observable variables
  RxBool isLoading = false.obs;

  // Dashboard stats
  RxInt totalCashOut = 0.obs;
  RxInt totalCashIn = 0.obs;
  RxInt netBalance = 0.obs;
  RxInt totalUsers = 0.obs;
  RxList<Transaction> recentTransactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load dashboard data from API
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final responseData = await _cacheService.getDashboardData();

      if (responseData['success'] == true) {
        final dashboard = DashboardModel.fromJson(responseData['data']);
        // Update individual stats
        totalCashOut.value = dashboard.totalCashOut;
        totalCashIn.value = dashboard.totalCashIn;
        netBalance.value = dashboard.netBalance;
        totalUsers.value = dashboard.totalUsers;
        recentTransactions.value = dashboard.recentTransactions;
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh dashboard data
  Future<void> refreshData() async {
    ApiClient().invalidateCache("/dashboard", 'GET');
    await loadDashboardData();
  }
}
