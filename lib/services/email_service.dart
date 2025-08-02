import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:staff_loan/utils/constants.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal() {
    _storage = GetStorage();
  }

  late final GetStorage _storage;

  String? get _token => _storage.read<String>('auth_token');

  Future<dynamic> send(String id) async {
    try {
      var response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.email}/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token',
            },
          )
          .timeout(Duration(milliseconds: AppConstants.timeoutDuration));
      if (response.statusCode != 200) {
        throw Exception('Failed to send email: ${response.body}');
      }
      return {'status': 'success', 'message': 'Email sent successfully'};
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }
}
