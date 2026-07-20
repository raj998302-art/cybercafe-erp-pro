import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/config/app_config.dart';
import '../../core/services/gst_service.dart';

/// Quick expenses tracker (Phase 8 — reports input).
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await DbHelper.query('expenses', orderBy: 'date DESC');
    _total = _items.fold(0.0,
        (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0));
    setState(() => _loading = false);
  }

  Future<void> _add() async {
    final cat = TextEditingController();
    final amt = TextEditingController(text: '0');
    final desc = TextEditingController();
    String mode = 'Cash';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Expense'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cat,
                  decoration: const InputDecoration(
                      labelText: 'Category (Rent, Electricity, etc.)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amt,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Amount (₹)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: mode,
                  decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder()),
                  items: AppConfig.paymentModes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setS(() => mode = v ?? 'Cash'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                await DbHelper.insert('expenses', {
                  'date': DateTime.now().toIso8601String(),
                  'category': cat.text.trim(),
                  'amount': double.tryParse(amt.text) ?? 0,
                  'payment_mode': mode,
                  'description': desc.text.trim(),
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

  Future<void> _delete(int id) async {
    await DbHelper.delete('expenses', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Expenses',
                            style: TextStyle(color: Colors.red)),
                        Text(GstService.formatMoney(_total),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Text('No expenses recorded',
                            style: TextStyle(color: Colors.grey.shade600)),
                      )
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final e = _items[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade50,
                              child: const Icon(Icons.money_off, color: Colors.red),
                            ),
                            title: Text(e['category'] ?? 'General'),
                            subtitle: Text(
                                '${(e['date'] as String?)?.substring(0, 10) ?? ""} • ${e['payment_mode'] ?? ""}${e['description'] != null && (e['description'] as String).isNotEmpty ? " • ${e['description']}" : ""}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(GstService.formatMoney(
                                    (e['amount'] as num?)?.toDouble() ?? 0),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _delete(e['id'] as int),
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
}
