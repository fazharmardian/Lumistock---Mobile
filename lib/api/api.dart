import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  final String _baseUrl = 'http://lumistock.test/api';
  String? _token;

  Future<void> _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    _token = localStorage.getString('token'); // Get directly
    // print('Retrieved Token: $_token');
  }

  Future<http.Response> authData(
      Map<String, dynamic> data, String apiUrl) async {
    var fullUrl = Uri.parse(_baseUrl + apiUrl);
    return await _sendRequest(() => http.post(
          fullUrl,
          body: jsonEncode(data),
          headers: _setHeaders(),
        ));
  }

  Future<http.Response> postData(String apiUrl, Map<String, dynamic> data,
      {Map<String, String>? headers}) async {
    await _getToken();
    var fullUrl = Uri.parse(_baseUrl + apiUrl);
    return await _sendRequest(() => http.post(
          fullUrl,
          body: jsonEncode(data),
          headers: headers,
        ));
  }

  Future<http.Response> getData(String apiUrl,
      {Map<String, String>? headers}) async {
    await _getToken();
    var fullUrl = Uri.parse(_baseUrl + apiUrl);
    return await http.get(fullUrl, headers: headers);
  }

  Future<http.Response> deleteData(String apiUrl,
      {Map<String, String>? headers}) async {
    await _getToken();
    var fullUrl = Uri.parse(_baseUrl + apiUrl);
    return await http.delete(fullUrl, headers: headers);
  }

  Map<String, String> _setHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  // Handle request with error handling
  Future<http.Response> _sendRequest(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception('Failed request: ${response.statusCode}');
      }
    } catch (e) {
      print('Request error 1: $e');
      rethrow; // Rethrow to handle it further if needed
    }
  }
}
