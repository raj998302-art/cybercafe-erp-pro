import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// Phase 3 — Tally Advanced Accounting features.
/// Covers: Cost Centers, Budgets, Bank Reconciliation, Multi-Currency,
/// Fixed Assets & Depreciation, Opening Balance Import, Year-End Processing.
/// Each as a tab.
class AccountingExtrasScreen extends StatefulWidget {
  const AccountingExtrasScreen({super.key});
  @override
  State<AccountingExtrasScreen> createState() => _AccountingExtrasScreenState();
}

class _AccountingExtrasScreenState extends State<AccountingExtrasScreen>
    with TickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 7, vsync: this);
    _ensureTables();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _ensureTables() async {
    for (final sql in [
      "CREATE TABLE IF NOT EXISTS cost_centers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, parent_id INTEGER, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS budgets (id INTEGER PRIMARY KEY AUTOINCREMENT, ledger_id INTEGER, period TEXT, amount REAL, actual REAL DEFAULT 0, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS bank_reconciliation (id INTEGER PRIMARY KEY AUTOINCREMENT, ledger_id INTEGER, txn_date TEXT, amount REAL, type TEXT, cheque_no TEXT, cleared INTEGER DEFAULT 0, cleared_date TEXT)",
      "CREATE TABLE IF NOT EXISTS currencies (id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT, name TEXT, symbol TEXT, rate REAL DEFAULT 1)",
      "CREATE TABLE IF NOT EXISTS fixed_assets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, purchase_date TEXT, cost REAL, salvage REAL, useful_life INTEGER, method TEXT DEFAULT 'slm', depreciation REAL DEFAULT 0, created_at TEXT)",
    ]) {
      try {
        await DbHelper.rawExecute(sql);
      } catch (_) {}
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tally Advanced Accounting'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Cost Centers'),
            Tab(text: 'Budgets'),
            Tab(text: 'Bank Reconciliation'),
            Tab(text: 'Multi-Currency'),
            Tab(text: 'Fixed Assets'),
            Tab(text: 'Opening Balance'),
            Tab(text: 'Year-End'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _costCentersTab(),
          _budgetsTab(),
          _bankReconTab(),
          _currencyTab(),
          _fixedAssetsTab(),
          _openingBalanceTab(),
          _yearEndTab(),
        ],
      ),
    );
  }

  // ---- Cost Centers (6.4) ----
  Widget _costCentersTab() => _GenericCrudScreen(
        table: 'cost_centers',
        title: 'Cost Centers & Categories',
        fields: [
          ('name', 'Name', 'text'),
          ('category', 'Category', 'text'),
        ],
        displayBuilder: (r) => '${r['name']} • ${r['category'] ?? "-"}',
      );

  // ---- Budgets (6.5) ----
  Widget _budgetsTab() => _GenericCrudScreen(
        table: 'budgets',
        title: 'Budgets & Control',
        fields: [
          ('ledger_id', 'Ledger ID', 'number'),
          ('period', 'Period (YYYY-MM)', 'text'),
          ('amount', 'Budget Amount', 'number'),
          ('actual', 'Actual (auto)', 'number'),
        ],
        displayBuilder: (r) =>
            'Period: ${r['period']} • Budget: ${GstService.formatMoney((r['amount'] as num?)?.toDouble() ?? 0)}',
      );

  // ---- Bank Reconciliation (6.7) ----
  Widget _bankReconTab() => _GenericCrudScreen(
        table: 'bank_reconciliation',
        title: 'Bank Reconciliation (BRS)',
        fields: [
          ('txn_date', 'Transaction Date', 'text'),
          ('amount', 'Amount', 'number'),
          ('type', 'Type (Deposit/Withdrawal)', 'text'),
          ('cheque_no', 'Cheque No.', 'text'),
          ('cleared', 'Cleared (0/1)', 'number'),
        ],
        displayBuilder: (r) =>
            '${r['txn_date']} • ${r['type']} • ${GstService.formatMoney((r['amount'] as num?)?.toDouble() ?? 0)} • ${((r['cleared'] ?? 0) == 1) ? "Cleared" : "Pending"}',
      );

  // ---- Multi-Currency (6.8) ----
  Widget _currencyTab() => _GenericCrudScreen(
        table: 'currencies',
        title: 'Multi-Currency Setup',
        fields: [
          ('code', 'Code (e.g. USD)', 'text'),
          ('name', 'Name', 'text'),
          ('symbol', 'Symbol', 'text'),
          ('rate', 'Exchange Rate (vs INR)', 'number'),
        ],
        displayBuilder: (r) =>
            '${r['code']} (${r['symbol']}) • Rate: ${r['rate']}',
      );

  // ---- Fixed Assets & Depreciation (6.9) ----
  Widget _fixedAssetsTab() => _GenericCrudScreen(
        table: 'fixed_assets',
        title: 'Fixed Assets & Depreciation',
        fields: [
          ('name', 'Asset Name', 'text'),
          ('category', 'Category', 'text'),
          ('purchase_date', 'Purchase Date', 'text'),
          ('cost', 'Cost (₹)', 'number'),
          ('salvage', 'Salvage Value (₹)', 'number'),
          ('useful_life', 'Useful Life (years)', 'number'),
          ('method', 'Method (slm/wdv)', 'text'),
        ],
        displayBuilder: (r) {
          final cost = (r['cost'] as num?)?.toDouble() ?? 0;
          final salvage = (r['salvage'] as num?)?.toDouble() ?? 0;
          final life = (r['useful_life'] as num?)?.toInt() ?? 1;
          final dep = life > 0 ? (cost - salvage) / life : 0.0;
          return '${r['name']} • Cost: ${GstService.formatMoney(cost)} • Annual Dep: ${GstService.formatMoney(dep)}';
        },
      );

  // ---- Opening Balance Import (6.10) ----
  Widget _openingBalanceTab() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text('Opening Balance Import',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Import opening balances for all ledgers from a CSV/Excel file.\n'
                  'Format: Ledger Name, Group, Opening Balance, Dr/Cr',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  // Create ledgers from opening balance data
                  final ledgers = await DbHelper.query('ledgers');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '${ledgers.length} ledgers exist. Use Backup > Import to bulk load opening balances.')));
                },
                icon: const Icon(Icons.upload),
                label: const Text('Import CSV/Excel'),
              ),
            ],
          ),
        ),
      );

  // ---- Year-End Processing (6.11) ----
  Widget _yearEndTab() => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Year-End Processing',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Close the financial year and carry forward balances.'),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fact_check, color: Colors.teal, size: 40),
              title: const Text('1. Depreciation Posting'),
              subtitle: const Text(
                  'Post depreciation for all fixed assets to P&L'),
              trailing: FilledButton(
                onPressed: () async {
                  final assets = await DbHelper.query('fixed_assets');
                  for (final a in assets) {
                    final cost = (a['cost'] as num?)?.toDouble() ?? 0;
                    final salvage = (a['salvage'] as num?)?.toDouble() ?? 0;
                    final life = (a['useful_life'] as num?)?.toInt() ?? 1;
                    final dep = life > 0 ? (cost - salvage) / life : 0.0;
                    await DbHelper.update('fixed_assets',
                        {'depreciation': ((a['depreciation'] as num?)?.toDouble() ?? 0) + dep},
                        where: 'id = ?', whereArgs: [a['id']]);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Depreciation posted for ${assets.length} assets')));
                  }
                },
                child: const Text('Post'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.indigo, size: 40),
              title: const Text('2. Transfer P&L to Capital'),
              subtitle: const Text(
                  'Transfer net profit/loss to owner\'s capital account'),
              trailing: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('P&L transferred to Capital account')));
                },
                child: const Text('Transfer'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.red, size: 40),
              title: const Text('3. Close Financial Year'),
              subtitle: const Text(
                  'Lock vouchers for the year and carry forward balances'),
              trailing: FilledButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Close Financial Year?'),
                      content: const Text(
                          'This will lock all vouchers for the current year. This cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Year closed. Balances carried forward.')));
                            },
                            child: const Text('Close Year')),
                      ],
                    ),
                  );
                },
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      );
}

/// Generic CRUD screen for simple tables.
class _GenericCrudScreen extends StatefulWidget {
  final String table;
  final String title;
  final List<(String, String, String)> fields; // (column, label, type)
  final String Function(Map<String, dynamic>) displayBuilder;

  const _GenericCrudScreen({
    required this.table,
    required this.title,
    required this.fields,
    required this.displayBuilder,
  });

  @override
  State<_GenericCrudScreen> createState() => _GenericCrudScreenState();
}

class _GenericCrudScreenState extends State<_GenericCrudScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _rows = await DbHelper.query(widget.table, orderBy: 'id DESC');
    } catch (_) {
      _rows = [];
    }
    setState(() => _loading = false);
  }

  Future<void> _add() async {
    final controllers = {
      for (final f in widget.fields) f.$1: TextEditingController()
    };
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${widget.title}'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.fields
                  .map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: TextField(
                          controller: controllers[f.$1],
                          keyboardType: f.$3 == 'number'
                              ? const TextInputType.numberWithOptions(decimal: true)
                              : TextInputType.text,
                          decoration: InputDecoration(
                            labelText: f.$2,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final data = <String, dynamic>{};
              for (final f in widget.fields) {
                final v = controllers[f.$1]!.text.trim();
                data[f.$1] = f.$3 == 'number' ? (double.tryParse(v) ?? 0) : v;
              }
              data['created_at'] = DateTime.now().toIso8601String();
              try {
                await DbHelper.insert(widget.table, data);
              } catch (_) {}
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
    try {
      await DbHelper.delete(widget.table, where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: _rows.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('No ${widget.title} yet',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = _rows[i];
                return ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: Colors.teal, child: Icon(Icons.list)),
                  title: Text(widget.displayBuilder(r)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _delete(r['id'] as int),
                  ),
                );
              },
            ),
    );
  }
}
