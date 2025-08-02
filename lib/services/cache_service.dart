import 'package:staff_loan/services/api_client.dart';
import 'package:staff_loan/utils/constants.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final ApiClient _apiClient = ApiClient();

  // Dashboard endpoints
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiClient.get(AppConstants.dashboardEndpoint);

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get dashboard data';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getStaffList() async {
    try {
      final response = await _apiClient.get(AppConstants.staffList);
      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get staff list';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> createLoan({
    required String valueDate,
    required String description,
    required double amount,
    required String transactionType,
    required int userId,
  }) async {
    try {
      final loanData = {
        'value_date': valueDate,
        'description': description,
        'amount': amount,
        'transaction_type': transactionType,
        'user_id': userId,
      };

      final response = await _apiClient.post(
        AppConstants.createLoanEndpoint,
        body: loanData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to create loan';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> createRepayment({
    required String valueDate,
    required String description,
    required double amount,
    required String transactionType,
    required int userId,
  }) async {
    try {
      final loanData = {
        'value_date': valueDate,
        'description': description,
        'amount': amount,
        'transaction_type': transactionType,
        'user_id': userId,
      };

      final response = await _apiClient.post(
        AppConstants.createLoanEndpoint,
        body: loanData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to create loan';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getStaffLoans() async {
    try {
      final response = await _apiClient.get(AppConstants.staffLoansEndpoint);
      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get staff loans';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getLoanStatement(String userId) async {
    try {
      final response = await _apiClient.get(
        "${AppConstants.loanStatement}/$userId",
      );
      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get loan statement';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> createStaff({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? image,
  }) async {
    try {
      final staffData = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      };

      if (image != null) {
        staffData['image'] = image;
      }

      final response = await _apiClient.post(
        AppConstants.createStaffEndpoint,
        body: staffData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to create staff';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    String? transactionType,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{'page': page.toString()};

      if (transactionType != null) {
        queryParams['transaction_type'] = transactionType;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        AppConstants.transactionsEndpoint,
        queryParams: queryParams,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get transactions';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> updateTransaction({
    required int transactionId,
    required String valueDate,
    required String description,
    required double amount,
    required String transactionType,
  }) async {
    try {
      final transactionData = {
        'value_date': valueDate,
        'description': description,
        'amount': amount,
        'transaction_type': transactionType,
      };

      final response = await _apiClient.post(
        '${AppConstants.transactionsEndpoint}/update/$transactionId',
        body: transactionData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to update transaction';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Profile endpoints
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get(AppConstants.profileEndpoint);

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get user profile';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Profile update endpoint
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    dynamic image, // Can be File for image upload
  }) async {
    try {
      final profileData = {
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      };

      // If image is provided, we would need to implement multipart upload
      // For now, let's handle it as a regular PUT request
      final response = await _apiClient.put(
        AppConstants.userProfileEndpoint,
        body: profileData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to update profile';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // User-specific dashboard endpoint
  Future<Map<String, dynamic>> getUserDashboardData() async {
    try {
      final response = await _apiClient.get(AppConstants.userDashboardEndpoint);

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get user dashboard data';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // User-specific history endpoint
  Future<Map<String, dynamic>> getUserHistory() async {
    try {
      final response = await _apiClient.get(AppConstants.userHistoryEndpoint);

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get user history';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }
}
