import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// Phase 5 — Purchase Management (8.9) + BOM (8.7) + Batch/Expiry (8.4) + Godown (8.5).
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});
  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> _godowns = [];
  List<Map<String, dynamic>> _bom = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _ensureTables();
    _load();
  }

  Future<void> _ensureTables() async {
    for (final sql in [
      "CREATE TABLE IF NOT EXISTS purchase_orders (id INTEGER PRIMARY KEY AUTOINCREMENT, po_number TEXT, date TEXT, supplier_id INTEGER, items TEXT, total REAL, status TEXT DEFAULT 'pending', created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS batches (id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER, batch_no TEXT, expiry_date TEXT, qty REAL, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS godowns (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS bom (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, component_id INTEGER, qty REAL, created_at TEXT)",
    ]) {
      try { await DbHelper.rawExecute(sql); } catch (_) {}
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _orders = await DbHelper.query('purchase_orders', orderBy: 'date DESC');
      _batches = await DbHelper.query('batches', orderBy: 'id DESC');
      _godowns = await DbHelper.query('godowns', orderBy: 'name');
      _bom = await DbHelper.query('bom', orderBy: 'id DESC');
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase & Inventory Advanced'),
        bottom: TabBar(controller: _tab, tabs: const [
          Tab(text: 'Purchase Orders'),
          Tab(text: 'Batches & Expiry'),
          Tab(text: 'Godowns'),
          Tab(text: 'BOM'),
        ]),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tab, children: [_poTab(), _batchTab(), _godownTab(), _bomTab()]),
    );
  }

  Widget _poTab() => _SimpleList(
        rows: _orders,
        emptyText: 'No purchase orders yet',
        display: (r) => '${r['po_number']} • ${r['date']?.toString().substring(0, 10) ?? ""} • ${GstService.formatMoney((r['total'] as num?)?.toDouble() ?? 0)} • ${r['status']}',
        onAdd: () => _form('New Purchase Order', [
          ('po_number', 'PO Number', 'text'),
          ('supplier_id', 'Supplier ID', 'number'),
          ('total', 'Total (₹)', 'number'),
        ], 'purchase_orders', {'date': DateTime.now().toIso8601String(), 'status': 'pending', 'items': '[]'}),
        onDelete: (id) async { await DbHelper.delete('purchase_orders', where: 'id = ?', whereArgs: [id]); _load(); },
      );

  Widget _batchTab() => _SimpleList(
        rows: _batches,
        emptyText: 'No batches tracked yet',
        display: (r) => 'Item #${r['item_id']} • Batch: ${r['batch_no']} • Qty: ${r['qty']} • Expiry: ${r['expiry_date'] ?? "-"}',
        onAdd: () => _form('Add Batch', [
          ('item_id', 'Item ID', 'number'),
          ('batch_no', 'Batch No.', 'text'),
          ('qty', 'Quantity', 'number'),
          ('expiry_date', 'Expiry Date', 'text'),
        ], 'batches'),
        onDelete: (id) async { await DbHelper.delete('batches', where: 'id = ?', whereArgs: [id]); _load(); },
      );

  Widget _godownTab() => _SimpleList(
        rows: _godowns,
        emptyText: 'No godowns yet',
        display: (r) => '${r['name']} • ${r['address'] ?? "-"}',
        onAdd: () => _form('Add Godown', [
          ('name', 'Name', 'text'),
          ('address', 'Address', 'text'),
        ], 'godowns'),
        onDelete: (id) async { await DbHelper.delete('godowns', where: 'id = ?', whereArgs: [id]); _load(); },
      );

  Widget _bomTab() => _SimpleList(
        rows: _bom,
        emptyText: 'No BOM entries yet',
        display: (r) => 'Product #${r['product_id']} → Component #${r['component_id']} × ${r['qty']}',
        onAdd: () => _form('Add BOM Entry', [
          ('product_id', 'Product ID', 'number'),
          ('component_id', 'Component ID', 'number'),
          ('qty', 'Quantity', 'number'),
        ], 'bom'),
        onDelete: (id) async { await DbHelper.delete('bom', where: 'id = ?', whereArgs: [id]); _load(); },
      );

  void _form(String title, List<(String, String, String)> fields, String table, [Map<String, dynamic>? extra]) {
    final controllers = {for (final f in fields) f.$1: TextEditingController()};
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: fields.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: TextField(controller: controllers[f.$1], keyboardType: f.$3 == 'number' ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: f.$2, border: const OutlineInputBorder())))).toList()))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            final data = <String, dynamic>{};
            for (final f in fields) { final v = controllers[f.$1]!.text.trim(); data[f.$1] = f.$3 == 'number' ? (double.tryParse(v) ?? 0) : v; }
            if (extra != null) data.addAll(extra);
            data['created_at'] = DateTime.now().toIso8601String();
            try { await DbHelper.insert(table, data); } catch (_) {}
            if (ctx.mounted) Navigator.pop(ctx);
            _load();
          }, child: const Text('Save')),
        ],
      ),
    );
  }
}

/// Phase 7 — GST Compliance extras: TDS, TCS, GSTR-2A/2B, GSTR-4, GSTR-9.
class GstComplianceScreen extends StatefulWidget {
  const GstComplianceScreen({super.key});
  @override
  State<GstComplianceScreen> createState() => _GstComplianceScreenState();
}

class _GstComplianceScreenState extends State<GstComplianceScreen>
    with TickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _ensureTables();
  }

  Future<void> _ensureTables() async {
    for (final sql in [
      "CREATE TABLE IF NOT EXISTS tds_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, party TEXT, pan TEXT, amount REAL, tds_rate REAL, tds_amount REAL, section TEXT, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS tcs_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, party TEXT, amount REAL, tcs_rate REAL, tcs_amount REAL, created_at TEXT)",
    ]) { try { await DbHelper.rawExecute(sql); } catch (_) {} }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Compliance & TDS/TCS'),
        bottom: TabBar(controller: _tab, isScrollable: true, tabs: const [
          Tab(text: 'TDS Entries'), Tab(text: 'TCS Entries'),
          Tab(text: 'GSTR-2A/2B'), Tab(text: 'GSTR-4'), Tab(text: 'GSTR-9'),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [
        _tdsTab(), _tcsTab(), _reconTab(), _gstr4Tab(), _gstr9Tab(),
      ]),
    );
  }

  Widget _tdsTab() => _AsyncList(
        load: () => DbHelper.query('tds_entries', orderBy: 'date DESC'),
        emptyText: 'No TDS entries yet',
        display: (r) => '${r['date']?.toString().substring(0, 10) ?? ""} • ${r['party']} • ${r['section']} • ${GstService.formatMoney((r['tds_amount'] as num?)?.toDouble() ?? 0)}',
        onAdd: () => _form('Add TDS Entry', [
          ('date', 'Date', 'text'), ('party', 'Party Name', 'text'),
          ('pan', 'PAN', 'text'), ('amount', 'Amount', 'number'),
          ('tds_rate', 'TDS Rate %', 'number'), ('section', 'Section', 'text'),
        ], 'tds_entries', compute: (d) { d['tds_amount'] = (d['amount'] as num).toDouble() * (d['tds_rate'] as num).toDouble() / 100; }),
        onDelete: (id) => DbHelper.delete('tds_entries', where: 'id = ?', whereArgs: [id]),
      );

  Widget _tcsTab() => _AsyncList(
        load: () => DbHelper.query('tcs_entries', orderBy: 'date DESC'),
        emptyText: 'No TCS entries yet',
        display: (r) => '${r['date']?.toString().substring(0, 10) ?? ""} • ${r['party']} • ${GstService.formatMoney((r['tcs_amount'] as num?)?.toDouble() ?? 0)}',
        onAdd: () => _form('Add TCS Entry', [
          ('date', 'Date', 'text'), ('party', 'Party Name', 'text'),
          ('amount', 'Amount', 'number'), ('tcs_rate', 'TCS Rate %', 'number'),
        ], 'tcs_entries', compute: (d) { d['tcs_amount'] = (d['amount'] as num).toDouble() * (d['tcs_rate'] as num).toDouble() / 100; }),
        onDelete: (id) => DbHelper.delete('tcs_entries', where: 'id = ?', whereArgs: [id]),
      );

  Widget _reconTab() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.compare_arrows, size: 80, color: Colors.brown),
    const SizedBox(height: 16),
    const Text('GSTR-2A / 2B Reconciliation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Reconcile purchase bills with auto-drafted GSTR-2B from GST portal.', textAlign: TextAlign.center),
    const SizedBox(height: 24),
    FilledButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload GSTR-2B JSON from GST portal'))); }, icon: const Icon(Icons.upload_file), label: const Text('Upload GSTR-2B')),
  ])));

  Widget _gstr4Tab() => Center(child: Card(margin: const EdgeInsets.all(32), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.receipt, size: 60, color: Colors.teal),
    const Text('GSTR-4 (Composition)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Quarterly return for composition dealers.\nTax at 1% / 5% / 6% of turnover.'),
    const SizedBox(height: 16),
    FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use Advanced Reports > Sales Summary'))); }, child: const Text('Generate')),
  ]))));

  Widget _gstr9Tab() => Center(child: Card(margin: const EdgeInsets.all(32), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.assessment, size: 60, color: Colors.indigo),
    const Text('GSTR-9 (Annual Return)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Consolidates all monthly returns for the financial year.'),
    const SizedBox(height: 16),
    FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use Advanced Reports > GST Summary'))); }, child: const Text('Generate')),
  ]))));

  void _form(String title, List<(String, String, String)> fields, String table, {Function(Map<String, dynamic>)? compute}) {
    final controllers = {for (final f in fields) f.$1: TextEditingController()};
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: fields.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: TextField(controller: controllers[f.$1], keyboardType: f.$3 == 'number' ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: f.$2, border: const OutlineInputBorder())))).toList()))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          final data = <String, dynamic>{};
          for (final f in fields) { final v = controllers[f.$1]!.text.trim(); data[f.$1] = f.$3 == 'number' ? (double.tryParse(v) ?? 0) : v; }
          if (compute != null) compute(data);
          data['created_at'] = DateTime.now().toIso8601String();
          try { await DbHelper.insert(table, data); } catch (_) {}
          if (ctx.mounted) Navigator.pop(ctx);
          setState(() {});
        }, child: const Text('Save')),
      ],
    ));
  }
}

class _SimpleList extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final String emptyText;
  final String Function(Map<String, dynamic>) display;
  final VoidCallback onAdd;
  final Future<void> Function(int) onDelete;
  const _SimpleList({required this.rows, required this.emptyText, required this.display, required this.onAdd, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: onAdd, child: const Icon(Icons.add)),
      body: rows.isEmpty ? Center(child: Text(emptyText, style: TextStyle(color: Colors.grey.shade600))) : ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final r = rows[i];
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.list, color: Colors.white)),
            title: Text(display(r)),
            trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => onDelete(r['id'] as int)),
          );
        },
      ),
    );
  }
}

class _AsyncList extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() load;
  final String emptyText;
  final String Function(Map<String, dynamic>) display;
  final VoidCallback onAdd;
  final Future<void> Function(int) onDelete;
  const _AsyncList({required this.load, required this.emptyText, required this.display, required this.onAdd, required this.onDelete});

  @override
  State<_AsyncList> createState() => _AsyncListState();
}

class _AsyncListState extends State<_AsyncList> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _rows = await widget.load(); } catch (_) { _rows = []; }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async { widget.onAdd(); await Future.delayed(const Duration(milliseconds: 300)); _load(); }, child: const Icon(Icons.add)),
      body: _rows.isEmpty ? Center(child: Text(widget.emptyText, style: TextStyle(color: Colors.grey.shade600))) : ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: _rows.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final r = _rows[i];
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.list, color: Colors.white)),
            title: Text(widget.display(r)),
            trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () async { await widget.onDelete(r['id'] as int); _load(); }),
          );
        },
      ),
    );
  }
}
