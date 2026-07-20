import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

/// Recycle Bin & Undo screen (Phase 14 — Recycle Bin & Undo).
/// Shows soft-deleted records that can be restored or permanently deleted.
class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});
  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  List<Map<String, dynamic>> _deleted = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ensureTable();
    _load();
  }

  Future<void> _ensureTable() async {
    await DbHelper.rawExecute('''
      CREATE TABLE IF NOT EXISTS recycle_bin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_table TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        record_data TEXT NOT NULL,
        deleted_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _load() async {
    _deleted = await DbHelper.query('recycle_bin', orderBy: 'deleted_at DESC');
    setState(() => _loading = false);
  }

  Future<void> _restore(int id, String table, String data) async {
    final map = Map<String, dynamic>.from(
        (await DbHelper.rawQuery('SELECT 1')).isEmpty
            ? {}
            : {});
    // Simple restore: re-insert the record
    try {
      final record = Map<String, dynamic>.from(_decode(data));
      record.remove('id');
      await DbHelper.insert(table, record);
      await DbHelper.delete('recycle_bin', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
    _load();
  }

  Map<String, dynamic> _decode(String s) {
    try {
      final d = s.replaceAll(RegExp(r"[{}\"]"), '').split(',');
      final m = <String, dynamic>{};
      for (final e in d) {
        final p = e.split(':');
        if (p.length == 2) m[p[0].trim()] = p[1].trim();
      }
      return m;
    } catch (_) {
      return {};
    }
  }

  Future<void> _purge(int id) async {
    await DbHelper.delete('recycle_bin', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  Future<void> _purgeAll() async {
    await DbHelper.rawExecute('DELETE FROM recycle_bin');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
        title: Text('Recycle Bin (${_deleted.length})'),
        actions: [
          if (_deleted.isNotEmpty)
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Empty Recycle Bin?'),
                  content: const Text(
                      'This will permanently delete all records. This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _purgeAll();
                        },
                        child: const Text('Empty')),
                  ],
                ),
              ),
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text('Empty All',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _deleted.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Recycle Bin is empty',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _deleted.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = _deleted[i];
                return ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: Colors.grey, child: Icon(Icons.delete)),
                  title: Text('${r['source_table']} #${r['record_id']}'),
                  subtitle: Text(
                      'Deleted: ${(r['deleted_at'] as String?)?.substring(0, 16) ?? ""}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => _restore(
                            r['id'] as int,
                            r['source_table'] as String,
                            r['record_data'] as String),
                        icon: const Icon(Icons.restore, color: Colors.green),
                        label: const Text('Restore',
                            style: TextStyle(color: Colors.green)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _purge(r['id'] as int),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
