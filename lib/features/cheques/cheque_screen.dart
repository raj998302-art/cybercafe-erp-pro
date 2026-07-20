import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// Cheque Management screen (Phase 14 — Cheque Management).
/// Tracks issued and received cheques with clearance status.
class ChequeScreen extends StatefulWidget {
  const ChequeScreen({super.key});
  @override
  State<ChequeScreen> createState() => _ChequeScreenState();
}

class _ChequeScreenState extends State<ChequeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _issued = [];
  List<Map<String, dynamic>> _received = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _ensureTable();
    _load();
  }

  Future<void> _ensureTable() async {
    await DbHelper.rawExecute('''
      CREATE TABLE IF NOT EXISTS cheques (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        cheque_no TEXT NOT NULL,
        bank TEXT,
        amount REAL,
        issue_date TEXT,
        clearance_date TEXT,
        party_name TEXT,
        status TEXT DEFAULT 'pending',
        notes TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _load() async {
    _issued = await DbHelper.query('cheques',
        where: "type = 'issued'", orderBy: 'issue_date DESC');
    _received = await DbHelper.query('cheques',
        where: "type = 'received'", orderBy: 'issue_date DESC');
    setState(() => _loading = false);
  }

  Future<void> _add(String type) async {
    final chequeNo = TextEditingController();
    final bank = TextEditingController();
    final amount = TextEditingController(text: '0');
    final party = TextEditingController();
    final clearance = TextEditingController();
    String status = 'pending';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(type == 'issued' ? 'Add Issued Cheque' : 'Add Received Cheque'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _f('Cheque Number *', chequeNo),
                  _f('Bank Name', bank),
                  _f('Amount (₹)', amount, num: true),
                  _f(type == 'issued' ? 'Payee Name' : 'Payer Name', party),
                  _f('Clearance Date (YYYY-MM-DD)', clearance),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(
                        labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'cleared', child: Text('Cleared')),
                      DropdownMenuItem(value: 'bounced', child: Text('Bounced')),
                    ],
                    onChanged: (v) => setS(() => status = v ?? 'pending'),
                  ),
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
                if (chequeNo.text.trim().isEmpty) return;
                await DbHelper.insert('cheques', {
                  'type': type,
                  'cheque_no': chequeNo.text.trim(),
                  'bank': bank.text.trim(),
                  'amount': double.tryParse(amount.text) ?? 0,
                  'issue_date': DateTime.now().toIso8601String().substring(0, 10),
                  'clearance_date': clearance.text.trim(),
                  'party_name': party.text.trim(),
                  'status': status,
                  'created_at': DateTime.now().toIso8601String(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    await DbHelper.update('cheques', {'status': status},
        where: 'id = ?', whereArgs: [id]);
    _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.delete('cheques', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final totalIssued =
        _issued.fold(0.0, (s, c) => s + ((c['amount'] as num?)?.toDouble() ?? 0));
    final totalReceived = _received.fold(
        0.0, (s, c) => s + ((c['amount'] as num?)?.toDouble() ?? 0));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cheque Management'),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: 'Issued (${_issued.length}) | ${GstService.formatMoney(totalIssued)}'),
            Tab(text: 'Received (${_received.length}) | ${GstService.formatMoney(totalReceived)}'),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'issued',
            onPressed: () => _add('issued'),
            tooltip: 'Add Issued Cheque',
            child: const Icon(Icons.call_made),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'received',
            onPressed: () => _add('received'),
            tooltip: 'Add Received Cheque',
            child: const Icon(Icons.call_received),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [_list(_issued), _list(_received)],
      ),
    );
  }

  Widget _list(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No cheques recorded'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = items[i];
        final status = c['status'] as String? ?? 'pending';
        final color = status == 'cleared'
            ? Colors.green
            : status == 'bounced'
                ? Colors.red
                : Colors.orange;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(Icons.account_balance_wallet, color: color),
          ),
          title: Text('Cheque #${c['cheque_no']}'),
          subtitle: Text(
              '${c['party_name'] ?? ""} • ${c['bank'] ?? ""} • ${c['issue_date'] ?? ""}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(GstService.formatMoney((c['amount'] as num?)?.toDouble() ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') {
                    _delete(c['id'] as int);
                  } else {
                    _updateStatus(c['id'] as int, v);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'cleared', child: Text('Mark Cleared')),
                  PopupMenuItem(value: 'pending', child: Text('Mark Pending')),
                  PopupMenuItem(value: 'bounced', child: Text('Mark Bounced')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _f(String label, TextEditingController c, {bool num = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
