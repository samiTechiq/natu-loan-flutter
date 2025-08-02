import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/models/loan_statement_model.dart';
import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/services/cache_service.dart';
import 'package:staff_loan/services/email_service.dart';
import 'package:staff_loan/utils/constants.dart';

class LoanStatementController extends GetxController {
  final CacheService _cacheService = CacheService();
  final EmailService _emailService = EmailService();

  // Observable variables
  var isLoading = false.obs;
  var isSendingEmail = false.obs;
  var loanStatement = Rxn<LoanStatement>();
  var errorMessage = ''.obs;

  // Staff details
  var staffId = ''.obs;
  var staffName = ''.obs;
  var staffEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from previous screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      staffId.value = arguments['staffId'] ?? '';
      staffName.value = arguments['staffName'] ?? '';
      staffEmail.value = arguments['staffEmail'] ?? '';

      // Load loan statement data
      loadLoanStatement();
    }
  }

  Future<void> loadLoanStatement() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (staffId.value == "") {
        throw 'Invalid staff ID';
      }

      final response = await _cacheService.getLoanStatement(staffId.value);
      loanStatement.value = LoanStatement.fromJson(response);

      if (!loanStatement.value!.success) {
        throw loanStatement.value!.message;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load loan statement1: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> emailStatement() async {
    try {
      isSendingEmail.value = true;
      errorMessage.value = '';

      if (staffId.value == "") {
        throw 'Invalid staff ID';
      }

      final response = await _emailService.send(staffId.value);

      if (response['status'] == 'success') {
        Get.snackbar(
          'Success',
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Fail to send email statement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isSendingEmail.value = false;
    }
  }

  Future<void> refreshData() async {
    ApiClient().invalidateCache(
      "${AppConstants.loanStatement}/${staffId.value}",
      'GET',
    );
    await loadLoanStatement();
  }

  // Calculate totals - now uses summary from API when available
  double get totalCashIn {
    if (loanStatement.value?.summary != null) {
      return loanStatement.value!.summary!.totalCashIn;
    }
    // Fallback to manual calculation if summary is not available
    if (loanStatement.value?.data == null) return 0.0;
    return loanStatement.value!.data.fold(
      0.0,
      (sum, item) => sum + item.cashIn,
    );
  }

  double get totalCashOut {
    if (loanStatement.value?.summary != null) {
      return loanStatement.value!.summary!.totalCashOut;
    }
    // Fallback to manual calculation if summary is not available
    if (loanStatement.value?.data == null) return 0.0;
    return loanStatement.value!.data.fold(
      0.0,
      (sum, item) => sum + item.cashOut,
    );
  }

  double get currentBalance {
    if (loanStatement.value?.summary != null) {
      return loanStatement.value!.summary!.totalOutstanding;
    }
    // Fallback to last transaction balance if summary is not available
    if (loanStatement.value?.data == null ||
        loanStatement.value!.data.isEmpty) {
      return 0.0;
    }
    return loanStatement.value!.data.last.balance;
  }
}
