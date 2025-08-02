import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:async';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = GetStorage();
  final _client = http.Client();

  // Default headers
  Map<String, String> get _defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization token if available
    final token = _storage.read('auth_token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // GET request
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      // Build URL with query parameters
      final uri = _buildUri(endpoint, queryParameters);

      // Merge headers
      final requestHeaders = {..._defaultHeaders};
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // _logRequest('GET', uri.toString(), null, requestHeaders);

      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(Duration(milliseconds: AppConstants.timeoutDuration));

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout. Please try again.';
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<ApiResponse> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      // Build URL with query parameters
      final uri = _buildUri(endpoint, queryParameters);

      // Merge headers
      final requestHeaders = {..._defaultHeaders};
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Encode body
      final body = data != null ? jsonEncode(data) : null;

      // _logRequest('POST', uri.toString(), body, requestHeaders);

      final response = await _client
          .post(uri, headers: requestHeaders, body: body)
          .timeout(Duration(milliseconds: AppConstants.timeoutDuration));

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout. Please try again.';
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<ApiResponse> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      // Build URL with query parameters
      final uri = _buildUri(endpoint, queryParameters);

      // Merge headers
      final requestHeaders = {..._defaultHeaders};
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Encode body
      final body = data != null ? jsonEncode(data) : null;

      _logRequest('PUT', uri.toString(), body, requestHeaders);

      final response = await _client
          .put(uri, headers: requestHeaders, body: body)
          .timeout(Duration(milliseconds: AppConstants.timeoutDuration));

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout. Please try again.';
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<ApiResponse> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      // Build URL with query parameters
      final uri = _buildUri(endpoint, queryParameters);

      // Merge headers
      final requestHeaders = {..._defaultHeaders};
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Encode body
      final body = data != null ? jsonEncode(data) : null;

      _logRequest('DELETE', uri.toString(), body, requestHeaders);

      final response = await _client
          .delete(uri, headers: requestHeaders, body: body)
          .timeout(Duration(milliseconds: AppConstants.timeoutDuration));

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timeout. Please try again.';
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final baseUri = Uri.parse(AppConstants.baseUrl);
    final fullPath = '${baseUri.path}$endpoint'.replaceAll('//', '/');

    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: fullPath,
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  // Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    _logResponse(response);

    // Handle 401 errors
    if (response.statusCode == 401) {
      _handleUnauthorized();
    }

    // Parse response body
    dynamic data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (e) {
      data = {'message': 'Invalid response format'};
    }

    return ApiResponse(
      statusCode: response.statusCode,
      data: data,
      isSuccess: response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  // Handle errors
  String _handleError(dynamic error) {
    if (error is String) {
      return error;
    }

    return 'An unexpected error occurred: ${error.toString()}';
  }

  // Handle unauthorized access
  void _handleUnauthorized() {
    _storage.remove('auth_token');
    _storage.remove('user_data');
    _storage.remove('is_logged_in');
  }

  // Log request
  void _logRequest(
    String method,
    String url,
    String? body,
    Map<String, String> headers,
  ) {
    print('🚀 [$method] $url');
    print('📋 Headers: $headers');
    if (body != null) {
      print('📦 Body: $body');
    }
  }

  // Log response
  void _logResponse(http.Response response) {
    print('📥 [${response.statusCode}] ${response.request?.url}');
    print('📄 Response: ${response.body}');
  }

  // Dispose client
  void dispose() {
    _client.close();
  }
}

// API Response wrapper
class ApiResponse {
  final int statusCode;
  final dynamic data;
  final bool isSuccess;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.isSuccess,
  });

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, isSuccess: $isSuccess, data: $data)';
  }
}
