import 'dart:io';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/database/database_init.dart';
import '../../core/database/db_helper.dart';

/// Windows file system backup manager.
/// Exports the entire SQLite database to a JSON file in a folder the
/// owner chooses, and supports restoring from such a file.
class BackupService {
  /// Returns the default backup folder under Documents/CyberCafeERP/Backups.
  static Future<String> defaultBackupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'CyberCafeERP', 'Backups'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  static Future<String> exportToFile([String? targetDir]) async {
    final dir = targetDir ?? await defaultBackupDir();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(p.join(dir, 'backup_$stamp.json'));
    final data = await exportToJson();
    file.writeAsStringSync(data);
    return file.path;
  }

  static Future<String> exportToJson() async {
    final db = await DatabaseInit.database;
    final tables = [
      'company', 'settings', 'customers', 'suppliers', 'items',
      'bills', 'bill_items', 'expenses', 'vouchers', 'voucher_entries',
      'ledgers', 'audit_log',
      // Phase 3
      'cost_centers', 'budgets', 'bank_reconciliation', 'currencies', 'fixed_assets',
      // Phase 5
      'categories', 'batches', 'godowns', 'stock_transfers', 'bom', 'purchase_orders',
      // Phase 7
      'tds_entries', 'tcs_entries',
      // Phase 9
      'employees', 'attendance', 'leaves', 'salary_runs',
      // Phase 14
      'vehicles', 'fuel_entries', 'documents',
      'reminders', 'cheques', 'notes', 'companies_list', 'recycle_bin',
    ];
    final out = <String, dynamic>{
      'meta': {
        'app': 'CyberCafe ERP Pro',
        'version': '1.0.0',
        'exported_at': DateTime.now().toIso8601String(),
      },
    };
    for (final t in tables) {
      try {
        out[t] = await db.query(t);
      } catch (_) {
        out[t] = [];
      }
    }
    return JsonEncoder.withIndent('  ').convert(out);
  }

  static Future<int> importFromFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) throw FileSystemException('File not found', path);
    final raw = file.readAsStringSync();
    return importFromJson(raw);
  }

  static Future<int> importFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final db = await DatabaseInit.database;
    final tables = [
      'company', 'settings', 'customers', 'suppliers', 'items',
      'bills', 'bill_items', 'expenses', 'vouchers', 'voucher_entries',
      'ledgers', 'audit_log',
      'cost_centers', 'budgets', 'bank_reconciliation', 'currencies', 'fixed_assets',
      'categories', 'batches', 'godowns', 'stock_transfers', 'bom', 'purchase_orders',
      'tds_entries', 'tcs_entries',
      'employees', 'attendance', 'leaves', 'salary_runs',
      'vehicles', 'fuel_entries', 'documents',
      'reminders', 'cheques', 'notes', 'companies_list', 'recycle_bin',
    ];
    int count = 0;
    await db.transaction((txn) async {
      for (final t in tables) {
        final rows = data[t];
        if (rows is! List) continue;
        try {
          await txn.execute('DELETE FROM $t');
        } catch (_) {}
        for (final r in rows) {
          try {
            await txn.insert(t, r as Map<String, Object?>,
                conflictAlgorithm: ConflictAlgorithm.replace);
            count++;
          } catch (_) {}
        }
      }
    });
    return count;
  }

  static Future<List<File>> listBackups([String? dir]) async {
    final d = Directory(dir ?? await defaultBackupDir());
    if (!d.existsSync()) return [];
    return d
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
  }
}
