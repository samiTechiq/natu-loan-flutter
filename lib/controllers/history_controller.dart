import 'package:get/get.dart';
import 'package:staff_loan/models/transaction_model.dart';
import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/services/cache_service.dart';

class HistoryController extends GetxController {
  final CacheService _cacheService = CacheService();

  // Observable variables
  var isLoading = false.obs;
  var transactionResponse = Rxn<TransactionResponse>();
  var errorMessage = ''.obs;
  var currentPage = 1.obs;
  var isLoadingMore = false.obs;

  // Filter variables
  var selectedTransactionType = 'all'.obs; // all, cash_in, cash_out
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        currentPage.value = 1;
      }

      errorMessage.value = '';

      final response = await _cacheService.getTransactions(
        page: loadMore ? currentPage.value + 1 : 1,
        transactionType:
            selectedTransactionType.value == 'all'
                ? null
                : selectedTransactionType.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      final newTransactionResponse = TransactionResponse.fromJson(response);

      if (!newTransactionResponse.success) {
        throw newTransactionResponse.message;
      }

      if (loadMore && transactionResponse.value != null) {
        // Append new transactions to existing list
        final existingTransactions = transactionResponse.value!.data.data;
        final newTransactions = newTransactionResponse.data.data;

        final combinedData = TransactionData(
          currentPage: newTransactionResponse.data.currentPage,
          data: [...existingTransactions, ...newTransactions],
          firstPageUrl: newTransactionResponse.data.firstPageUrl,
          from: transactionResponse.value!.data.from,
          lastPage: newTransactionResponse.data.lastPage,
          lastPageUrl: newTransactionResponse.data.lastPageUrl,
          links: newTransactionResponse.data.links,
          nextPageUrl: newTransactionResponse.data.nextPageUrl,
          path: newTransactionResponse.data.path,
          perPage: newTransactionResponse.data.perPage,
          prevPageUrl: newTransactionResponse.data.prevPageUrl,
          to: newTransactionResponse.data.to,
          total: newTransactionResponse.data.total,
        );

        transactionResponse.value = TransactionResponse(
          success: newTransactionResponse.success,
          message: newTransactionResponse.message,
          data: combinedData,
        );

        currentPage.value = newTransactionResponse.data.currentPage;
      } else {
        transactionResponse.value = newTransactionResponse;
        currentPage.value = newTransactionResponse.data.currentPage;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load transactions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    ApiClient().clearCache();
    await loadTransactions();
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value ||
        transactionResponse.value == null ||
        transactionResponse.value!.data.nextPageUrl == null) {
      return;
    }

    await loadTransactions(loadMore: true);
  }

  void filterByTransactionType(String type) {
    selectedTransactionType.value = type;
    loadTransactions();
  }

  void searchTransactions(String query) {
    searchQuery.value = query;
    loadTransactions();
  }

  bool get hasMorePages {
    return transactionResponse.value?.data.nextPageUrl != null;
  }

  int get totalTransactions {
    return transactionResponse.value?.data.total ?? 0;
  }

  List<Transaction> get transactions {
    return transactionResponse.value?.data.data ?? [];
  }
}
