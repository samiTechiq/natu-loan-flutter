import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http_cached_client/http_cache_client.dart';
import 'package:http_cached_client/utils.dart';
import 'package:staff_loan/utils/constants.dart';

class ApiClient {
  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();

  // Factory constructor
  factory ApiClient() => _instance;

  // Private constructor
  ApiClient._internal() {
    _client = HttpCacheClient(
      baseUrl: AppConstants.baseUrl,
      cacheTimeout: Duration(minutes: 10), // Default is 5 minutes
    );
    _storage = GetStorage();
  }

  late final HttpCacheClient _client;
  late final GetStorage _storage;

  String? get _token => _storage.read<String>('auth_token');

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // GET method with optional caching
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    final response = await _client.get(
      url,
      headers: _headers,
      queryParams: queryParams,
    );
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
      isSuccess: response.statusCode == 200,
    );
  }

  // POST method
  Future<ApiResponse> post(String url, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
      isSuccess: response.statusCode == 201,
    );
  }

  // PUT method
  Future<ApiResponse> put(String url, {Map<String, dynamic>? body}) async {
    final response = await _client.put(
      url,
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
      isSuccess: response.statusCode == 201,
    );
  }

  // DELETE method
  Future<ApiResponse> delete(String url) async {
    final response = await _client.delete(url, headers: _headers);
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
      isSuccess: response.statusCode == 200 || response.statusCode == 201,
    );
  }

  // invalidate cache for a specific URL
  Future<void> invalidateCache(String url, method) async {
    _client.invalidateCache(
      uri: url,
      method: REQUEST_METHODS.values.firstWhere(
        (e) => e.toString().toUpperCase() == method.toUpperCase(),
        orElse: () => REQUEST_METHODS.GET,
      ),
    );
  }

  Future<void> clearCache() async {
    _client.clearCache();
  }
}

// API Response wrapper
class ApiResponse {
  final int statusCode;
  final dynamic data;
  final bool isSuccess;
  final String? message;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.isSuccess,
    this.message,
  });

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, isSuccess: $isSuccess, data: $data, message: $message)';
  }
}
