import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkHandler {
  static Future<Map<String, dynamic>?> safePost(
    Uri url, {
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> safeGet(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>?> safeGetList(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? _handleResponse(http.Response response) {
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }
}
