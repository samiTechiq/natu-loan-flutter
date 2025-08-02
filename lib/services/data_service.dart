import '../services/api_service.dart';
import '../utils/constants.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final ApiService _apiService = ApiService();

  // Authentication endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Login failed';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post(AppConstants.logoutEndpoint);

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Logout failed';
      }

      return response.data;
    } catch (e) {
      // Even if logout fails on the server, we should clear local data
      print('Logout error: $e');
      return {}; // Return empty map to indicate completion
    }
  }

  // User endpoints
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get(AppConstants.profileEndpoint);

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get user profile';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get(
        AppConstants.usersEndpoint,
        queryParameters: queryParams,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get users';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Dashboard endpoints
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiService.get(AppConstants.dashboardEndpoint);

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get dashboard data';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Loans endpoints
  Future<Map<String, dynamic>> getLoans({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get(
        AppConstants.loansEndpoint,
        queryParameters: queryParams,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get loans';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> createLoan(Map<String, dynamic> loanData) async {
    try {
      final response = await _apiService.post(
        AppConstants.loansEndpoint,
        data: loanData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to create loan';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> updateLoan(
    int loanId,
    Map<String, dynamic> loanData,
  ) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.loansEndpoint}/$loanId',
        data: loanData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to update loan';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> deleteLoan(int loanId) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.loansEndpoint}/$loanId',
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to delete loan';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // History endpoints
  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int limit = 10,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await _apiService.get(
        AppConstants.historyEndpoint,
        queryParameters: queryParams,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to get history';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Change password endpoint
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final passwordData = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      };

      final response = await _apiService.post(
        AppConstants.changePassword,
        data: passwordData,
      );

      if (!response.isSuccess) {
        throw response.data['message'] ?? 'Failed to change password';
      }

      return response.data;
    } catch (e) {
      throw e.toString();
    }
  }
}
