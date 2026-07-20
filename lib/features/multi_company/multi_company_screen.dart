import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

/// Multi-Company & Multi-Branch management (Phase 11).
/// Allows the owner to manage multiple businesses (e.g., cyber cafe +
/// stationery shop) with separate books, all in one app.
class MultiCompanyScreen extends StatefulWidget {
  const MultiCompanyScreen({super.key});
  @override
  State<MultiCompanyScreen> createState() => _MultiCompanyScreenState();
}

class _MultiCompanyScreenState extends State<MultiCompanyScreen> {
  List<Map<String, dynamic>> _companies = [];
  int? _activeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ensureTable();
    _load();
  }

  Future<void> _ensureTable() async {
    await DbHelper.rawExecute('''
      CREATE TABLE IF NOT EXISTS companies_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gstin TEXT,
        pan TEXT,
        address TEXT,
        state TEXT,
        phone TEXT,
        email TEXT,
        is_active INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');
  }

  Future<void> _load() async {
    _companies = await DbHelper.query('companies_list', orderBy: 'name');
    final active =
        _companies.where((c) => (c['is_active'] ?? 0) == 1).toList();
    _activeId = active.isNotEmpty ? active.first['id'] as int : null;
    setState(() => _loading = false);
  }

  Future<void> _setActive(int id) async {
    await DbHelper.rawExecute('UPDATE companies_list SET is_active = 0');
    await DbHelper.update('companies_list', {'is_active': 1},
        where: 'id = ?', whereArgs: [id]);
    _load();
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final gstin = TextEditingController();
    final pan = TextEditingController();
    final address = TextEditingController();
    final state = TextEditingController(text: 'Maharashtra');
    final phone = TextEditingController();
    final email = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Company / Branch'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _f('Company Name *', name),
                _f('GSTIN', gstin, upper: true),
                _f('PAN', pan, upper: true),
                _f('Address', address, max: 2),
                _f('State', state),
                _f('Phone', phone),
                _f('Email', email),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              await DbHelper.insert('companies_list', {
                'name': name.text.trim(),
                'gstin': gstin.text.trim().toUpperCase(),
                'pan': pan.text.trim().toUpperCase(),
                'address': address.text.trim(),
                'state': state.text.trim(),
                'phone': phone.text.trim(),
                'email': email.text.trim(),
                'is_active': 0,
                'created_at': DateTime.now().toIso8601String(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(int id) async {
    await DbHelper.delete('companies_list', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Active: ${_companies.where((c) => (c['is_active'] ?? 0) == 1).map((c) => c['name']).join(", ") ?? "None"}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text(
                            'All bills, reports, and GST are tracked under the active company.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.business),
                label: const Text('Add Company'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _companies.isEmpty
                ? Center(
                    child: Text('No companies yet',
                        style: TextStyle(color: Colors.grey.shade600)),
                  )
                : ListView.separated(
                    itemCount: _companies.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = _companies[i];
                      final isActive = (c['is_active'] ?? 0) == 1;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? Colors.green
                              : Colors.grey.shade300,
                          child: Icon(Icons.business,
                              color: isActive ? Colors.white : Colors.grey),
                        ),
                        title: Text(c['name'],
                            style: TextStyle(
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        subtitle: Text(
                            '${c['gstin'] ?? "No GSTIN"} • ${c['state'] ?? ""}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isActive)
                              FilledButton.tonal(
                                onPressed: () => _setActive(c['id'] as int),
                                child: const Text('Set Active'),
                              )
                            else
                              const Chip(
                                  label: Text('ACTIVE'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white)),
                            PopupMenuButton<String>(
                              onSelected: (v) =>
                                  _delete(c['id'] as int),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController c,
      {bool upper = false, int max = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        maxLines: max,
        textCapitalization:
            upper ? TextCapitalization.characters : TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
