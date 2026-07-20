import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

class _Supplier {
  final int? id;
  final String name;
  final String phone;
  final String gstin;
  final String address;
  final double openingBalance;
  final String balanceType;
  final String notes;

  _Supplier({
    this.id,
    required this.name,
    this.phone = '',
    this.gstin = '',
    this.address = '',
    this.openingBalance = 0,
    this.balanceType = 'credit',
    this.notes = '',
  });

  factory _Supplier.fromMap(Map<String, dynamic> m) => _Supplier(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        gstin: (m['gstin'] ?? '') as String,
        address: (m['address'] ?? '') as String,
        openingBalance: (m['opening_balance'] as num?)?.toDouble() ?? 0,
        balanceType: (m['balance_type'] ?? 'credit') as String,
        notes: (m['notes'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone,
        'gstin': gstin,
        'address': address,
        'opening_balance': openingBalance,
        'balance_type': balanceType,
        'notes': notes,
      };
}

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});
  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final _search = TextEditingController();
  List<_Supplier> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String q = ''}) async {
    setState(() => _loading = true);
    final rows = q.isEmpty
        ? await DbHelper.query('suppliers', orderBy: 'name COLLATE NOCASE ASC')
        : await DbHelper.rawQuery(
            'SELECT * FROM suppliers WHERE name LIKE ? OR phone LIKE ? ORDER BY name COLLATE NOCASE ASC',
            ['%$q%', '%$q%'],
          );
    _items = rows.map(_Supplier.fromMap).toList();
    setState(() => _loading = false);
  }

  Future<void> _upsert(_Supplier s) async {
    final now = DateTime.now().toIso8601String();
    final map = {...s.toMap(), 'updated_at': now};
    if (s.id == null) {
      map['created_at'] = now;
      await DbHelper.insert('suppliers', map);
    } else {
      await DbHelper.update('suppliers', map, where: 'id = ?', whereArgs: [s.id]);
    }
    _load(q: _search.text);
  }

  Future<void> _delete(int id) async {
    await DbHelper.delete('suppliers', where: 'id = ?', whereArgs: [id]);
    _load(q: _search.text);
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
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    labelText: 'Search suppliers',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _load(q: v),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _showForm(context),
                icon: const Icon(Icons.person_add),
                label: const Text('New Supplier'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Text('No suppliers yet',
                            style: TextStyle(color: Colors.grey.shade600)),
                      )
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final s = _items[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade50,
                              child: const Icon(Icons.local_shipping,
                                  color: Colors.orange),
                            ),
                            title: Text(s.name),
                            subtitle: Text(
                                '${s.phone.isEmpty ? "No phone" : s.phone}${s.gstin.isNotEmpty ? " • GSTIN: ${s.gstin}" : ""}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(GstService.formatMoney(s.openingBalance),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      _showForm(context, supplier: s);
                                    } else if (v == 'delete') {
                                      _delete(s.id!);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
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

  void _showForm(BuildContext context, {_Supplier? supplier}) {
    final name = TextEditingController(text: supplier?.name ?? '');
    final phone = TextEditingController(text: supplier?.phone ?? '');
    final gstin = TextEditingController(text: supplier?.gstin ?? '');
    final address = TextEditingController(text: supplier?.address ?? '');
    final opening = TextEditingController(
        text: (supplier?.openingBalance ?? 0).toStringAsFixed(0));
    final notes = TextEditingController(text: supplier?.notes ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(supplier == null ? 'New Supplier' : 'Edit Supplier'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _f('Name *', name),
                _f('Phone', phone),
                _f('GSTIN', gstin, upper: true),
                _f('Address', address, max: 2),
                _f('Opening Balance', opening, num: true),
                _f('Notes', notes, max: 2),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              _upsert(_Supplier(
                id: supplier?.id,
                name: name.text.trim(),
                phone: phone.text.trim(),
                gstin: gstin.text.trim().toUpperCase(),
                address: address.text.trim(),
                openingBalance: double.tryParse(opening.text) ?? 0,
                // Preserve existing balanceType — don't silently reset to 'credit'
                balanceType: supplier?.balanceType ?? 'credit',
                notes: notes.text.trim(),
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController c,
      {bool num = false, bool upper = false, int max = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
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
