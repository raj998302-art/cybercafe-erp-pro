import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_init.dart';

/// Generic CRUD helper over SQLite for offline-first storage.
class DbHelper {
  static Future<Database> get _db => DatabaseInit.database;

  static Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await _db;
    return db.insert(table, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await _db;
    return db.query(table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
  }

  static Future<Map<String, dynamic>?> first(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = await query(table,
        where: where, whereArgs: whereArgs, limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await _db;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  static Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await _db;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<int> count(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await _db;
    final r = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs);
    return r.first['c'] as int? ?? 0;
  }

  static Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? args]) async {
    final db = await _db;
    return db.rawQuery(sql, args);
  }

  static Future<int> rawExecute(String sql, [List<Object?>? args]) async {
    final db = await _db;
    await db.execute(sql, args);
    return 1;
  }

  static String encodeList(List<dynamic> list) => jsonEncode(list);
  static List<dynamic> decodeList(String? s) =>
      s == null ? [] : jsonDecode(s) as List<dynamic>;
}
