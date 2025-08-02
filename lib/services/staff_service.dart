import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:staff_loan/utils/constants.dart';

class StaffService {
  static final StaffService _instance = StaffService._internal();
  factory StaffService() => _instance;
  StaffService._internal() {
    _storage = GetStorage();
  }

  late final GetStorage _storage;

  String? get _token => _storage.read<String>('auth_token');

  Future create(String data, {String? fileUrl}) async {
    try {
      http.Response? response;
      String? responseBody;

      if (fileUrl != null) {
        // Multipart logic
        final fullFileUrl = File(fileUrl);
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("${AppConstants.baseUrl}/register"),
        );
        request.headers['X-Requested-With'] = 'XMLHttpRequest';
        request.headers['Authorization'] = 'Bearer $_token';

        Map<String, dynamic> jsonFields = jsonDecode(data);
        jsonFields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
        request.files.add(
          await http.MultipartFile.fromPath('image', fullFileUrl.path),
        );
        final streamedResponse = await request.send();
        responseBody = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 201) {
          return jsonDecode(responseBody);
        } else {
          // Try to parse error response
          try {
            final errorJson = jsonDecode(responseBody);
            throw errorJson;
          } catch (e) {
            throw {'message': 'Failed to create staff', 'errors': {}};
          }
        }
      } else {
        // Normal post
        Map<String, dynamic> request = {};
        Map<String, dynamic> jsonFields = jsonDecode(data);
        jsonFields.forEach((key, value) {
          request[key] = value.toString();
        });
        response = await http.post(
          Uri.parse("${AppConstants.baseUrl}/register"),
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'Authorization': 'Bearer $_token',
          },
          body: request.isNotEmpty ? jsonEncode(request) : null,
        );
        responseBody = response.body;

        if (response.statusCode == 201) {
          return jsonDecode(responseBody);
        } else {
          // Try to parse error response
          try {
            final errorJson = jsonDecode(responseBody);
            throw errorJson;
          } catch (e) {
            print(e.toString());
            throw {'message': 'Failed to create staff', 'errors': {}};
          }
        }
      }
    } catch (e) {
      // Just pass whatever is thrown upwards
      print(e.toString());
      throw e.toString();
    }
  }

  Future update(int staffId, String data, {String? fileUrl}) async {
    try {
      http.Response? response;
      String? responseBody;

      if (fileUrl != null) {
        // Multipart logic for update with image
        final fullFileUrl = File(fileUrl);
        var request = http.MultipartRequest(
          'POST', // Laravel uses POST with _method=PUT for file uploads
          Uri.parse("${AppConstants.baseUrl}/users/update/$staffId"),
        );
        request.headers['X-Requested-With'] = 'XMLHttpRequest';
        request.headers['Authorization'] = 'Bearer $_token';

        Map<String, dynamic> jsonFields = jsonDecode(data);
        //jsonFields['_method'] = 'PUT'; // Laravel method spoofing
        jsonFields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
        request.files.add(
          await http.MultipartFile.fromPath('image', fullFileUrl.path),
        );
        final streamedResponse = await request.send();
        responseBody = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 200) {
          return jsonDecode(responseBody);
        } else {
          // Try to parse error response
          try {
            final errorJson = jsonDecode(responseBody);
            throw errorJson;
          } catch (e) {
            throw {'message': 'Failed to update staff', 'errors': {}};
          }
        }
      } else {
        // Normal POST request

        response = await http.post(
          Uri.parse("${AppConstants.baseUrl}/users/update/$staffId"),
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'Authorization': 'Bearer $_token',
          },
          body: data,
        );
        responseBody = response.body;

        if (response.statusCode == 200) {
          return jsonDecode(responseBody);
        } else {
          // Try to parse error response
          try {
            final errorJson = jsonDecode(responseBody);
            throw errorJson;
          } catch (e) {
            debugPrint(e.toString());
            throw {'message': 'Failed to update staff', 'errors': e.toString()};
          }
        }
      }
    } catch (e) {
      // Just pass whatever is thrown upwards
      debugPrint(e.toString());
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getStaff(int staffId) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/users/$staffId"),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Try to parse error response
        try {
          final errorJson = jsonDecode(response.body);
          throw errorJson;
        } catch (e) {
          throw {'message': 'Failed to get staff details', 'errors': {}};
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateProfile(String data, {String? fileUrl}) async {
    try {
      http.Response? response;
      String? responseBody;

      if (fileUrl != null) {
        // Multipart logic for update with image
        final fullFileUrl = File(fileUrl);
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
            "${AppConstants.baseUrl}${AppConstants.userProfileEndpoint}",
          ),
        );
        request.headers['X-Requested-With'] = 'XMLHttpRequest';
        request.headers['Authorization'] = 'Bearer $_token';

        Map<String, dynamic> jsonFields = jsonDecode(data);
        jsonFields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
        request.files.add(
          await http.MultipartFile.fromPath('image', fullFileUrl.path),
        );
        final streamedResponse = await request.send();
        responseBody = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 200) {
          return jsonDecode(responseBody);
        } else {
          // Try to parse error response
          try {
            final errorJson = jsonDecode(responseBody);
            throw errorJson;
          } catch (e) {
            throw {'message': 'Failed to update profile', 'errors': {}};
          }
        }
      } else {
        // Normal POST request
        response = await http.post(
          Uri.parse(
            "${AppConstants.baseUrl}${AppConstants.userProfileEndpoint}",
          ),
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'Authorization': 'Bearer $_token',
          },
          body: data,
        );
        responseBody = response.body;

        if (response.statusCode == 200) {
          return jsonDecode(responseBody);
        } else {
          // Try to parse error response
          try {
            final errorJson = jsonDecode(responseBody);
            throw errorJson;
          } catch (e) {
            throw {'message': 'Failed to update profile', 'errors': {}};
          }
        }
      }
    } catch (e) {
      // Just pass whatever is thrown upwards
      throw e.toString();
    }
  }
}
