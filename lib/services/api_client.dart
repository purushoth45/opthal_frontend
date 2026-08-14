import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ophthal_vivaedge/core/constants/api_config.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';

class ApiClient {
  final http.Client _client;
  final SecureStorageService _storageService;

  ApiClient({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _getHeaders();
    final response = await _client.get(url, headers: headers).timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _getHeaders();
    final response = await _client
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _getHeaders();
    final response = await _client
        .put(url, headers: headers, body: jsonEncode(body))
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _getHeaders();
    final response = await _client.delete(url, headers: headers).timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Server error occurred (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          errorMessage = body['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
