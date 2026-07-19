import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Talks to the Node.js + MongoDB backend for cloud sync.
/// All writes go to local SQLite first (offline-first); this service
/// pushes/pulls to keep MongoDB in sync.
class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  String get _base => AppConfig.apiBaseUrl;

  Future<Map<String, dynamic>> _get(String path) async {
    final res = await http.get(Uri.parse('$_base$path'));
    return _decode(res);
  }

  Future<Map<String, dynamic>> _post(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      Uri.parse('$_base$path'),
      headers: {'Content-Type': 'application/json'},
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> _put(String path, [Map<String, dynamic>? body]) async {
    final res = await http.put(
      Uri.parse('$_base$path'),
      headers: {'Content-Type': 'application/json'},
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    final res = await http.delete(Uri.parse('$_base$path'));
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(body['message'] ?? 'Request failed',
          res.statusCode, body);
    }
    return body;
  }

  // ----- Health -----
  Future<bool> ping() async {
    try {
      await _get('/health');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ----- Customers -----
  Future<List<Map<String, dynamic>>> fetchCustomers() async =>
      (_get('/customer')['data'] as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> c) =>
      _post('/customer', c);
  Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> c) =>
      _put('/customer/$id', c);
  Future<void> deleteCustomer(String id) => _delete('/customer/$id');

  // ----- Items -----
  Future<List<Map<String, dynamic>>> fetchItems() async =>
      (_get('/item')['data'] as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> i) =>
      _post('/item', i);
  Future<Map<String, dynamic>> seedItems() => _get('/item/seed');

  // ----- Bills -----
  Future<List<Map<String, dynamic>>> fetchBills() async =>
      (_get('/bill')['data'] as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> createBill(Map<String, dynamic> b) =>
      _post('/bill', b);
  Future<Map<String, dynamic>> todayBillCount() => _get('/bill/today/count');
  Future<Map<String, dynamic>> monthSummary() => _get('/bill/month/summary');

  // ----- Reports -----
  Future<Map<String, dynamic>> salesSummary() => _get('/report/sales-summary');
  Future<Map<String, dynamic>> gstSummary() => _get('/report/gst-summary');

  // ----- GST -----
  Future<Map<String, dynamic>> gstr1(String from, String to) =>
      _get('/gst/gstr1?from=$from&to=$to');
  Future<Map<String, dynamic>> gstr3b(String month) =>
      _get('/gst/gstr3b?month=$month');

  // ----- Backup / Sync -----
  Future<Map<String, dynamic>> exportAll() => _get('/backup/export');
  Future<Map<String, dynamic>> importAll(Map<String, dynamic> data) =>
      _post('/backup/import', data);
  Future<Map<String, dynamic>> syncAll() => _get('/sync/all');
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? body;
  ApiException(this.message, this.statusCode, [this.body]);
  @override
  String toString() => 'ApiException($statusCode): $message';
}
