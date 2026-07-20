import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';
import '../../core/config/app_config.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});
  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  int _tab = 0;
  List<Map<String, dynamic>> _vouchers = [];
  List<Map<String, dynamic>> _ledgers = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _vouchers = await DbHelper.query('vouchers', orderBy: 'date DESC');
    _ledgers = await DbHelper.query('ledgers', orderBy: 'name COLLATE NOCASE ASC');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Accounting (Tally-style)',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              FilledButton.icon(
                onPressed: _newVoucher,
                icon: const Icon(Icons.add),
                label: const Text('New Voucher'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: [_tab == 0, _tab == 1],
            onPressed: (i) => setState(() => _tab = i),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Vouchers (Day Book)'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Ledgers (Chart of Accounts)'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tab == 0
                    ? _vouchersView()
                    : _ledgersView(),
          ),
        ],
      ),
    );
  }

  Widget _vouchersView() {
    if (_vouchers.isEmpty) {
      return Center(
          child: Text('No vouchers yet',
              style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.separated(
      itemCount: _vouchers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final v = _vouchers[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade50,
            child: const Icon(Icons.swap_horiz, color: Colors.purple),
          ),
          title: Text('${v['voucher_type']} • ${v['voucher_number']}'),
          subtitle: Text(
              '${(v['date'] as String?)?.substring(0, 10) ?? ""} • ${v['narration'] ?? ""}'),
          trailing: Text(GstService.formatMoney((v['amount'] as num?)?.toDouble() ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _ledgersView() {
    if (_ledgers.isEmpty) {
      return Center(
          child: Text('No ledgers yet',
              style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.separated(
      itemCount: _ledgers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final l = _ledgers[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.account_balance, color: Colors.blue),
          ),
          title: Text(l['name']),
          subtitle: Text('${l['group_name'] ?? "-"} • ${l['balance_type'] ?? ""}'),
          trailing: Text(GstService.formatMoney((l['opening_balance'] as num?)?.toDouble() ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  void _newVoucher() {
    final typeCtrl = TextEditingController();
    final narrCtrl = TextEditingController();
    final amtCtrl = TextEditingController(text: '0');
    String vtype = 'Receipt';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
        title: const Text('New Voucher'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: vtype,
                decoration: const InputDecoration(
                    labelText: 'Voucher Type',
                    border: OutlineInputBorder()),
                items: AppConfig.voucherTypes
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setS(() => vtype = v ?? 'Receipt'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: narrCtrl,
                decoration: const InputDecoration(
                    labelText: 'Narration', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amtCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Amount (₹)', border: OutlineInputBorder()),
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
              final amt = double.tryParse(amtCtrl.text) ?? 0;
              // Generate unique voucher number using timestamp
              final ts = DateTime.now().millisecondsSinceEpoch;
              final vno = '${vtype.substring(0, 3).toUpperCase()}-$ts';
              final voucherId = await DbHelper.insert('vouchers', {
                'voucher_type': vtype,
                'voucher_number': vno,
                'date': DateTime.now().toIso8601String(),
                'narration': narrCtrl.text,
                'amount': amt,
                'created_at': DateTime.now().toIso8601String(),
              });
              // Double-entry: create Dr and Cr entries based on voucher type
              final debitLedger = _debitLedgerFor(vtype);
              final creditLedger = _creditLedgerFor(vtype);
              await DbHelper.insert('voucher_entries', {
                'voucher_id': voucherId,
                'ledger': debitLedger,
                'debit': amt,
                'credit': 0,
                'narration': narrCtrl.text,
              });
              await DbHelper.insert('voucher_entries', {
                'voucher_id': voucherId,
                'ledger': creditLedger,
                'debit': 0,
                'credit': amt,
                'narration': narrCtrl.text,
              });
              if (mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
      ),
    );
  }

  /// Returns the debit ledger for a voucher type (Tally double-entry rules).
  String _debitLedgerFor(String type) {
    switch (type) {
      case 'Receipt': return 'Cash/Bank';
      case 'Payment': return 'Expense/Ledger';
      case 'Sales': return 'Customer (Debtor)';
      case 'Purchase': return 'Purchase Account';
      case 'Journal': return 'Ledger A';
      case 'Credit Note': return 'Sales Return';
      case 'Debit Note': return 'Supplier (Creditor)';
      case 'Contra': return 'Cash';
      default: return 'Ledger A';
    }
  }

  /// Returns the credit ledger for a voucher type.
  String _creditLedgerFor(String type) {
    switch (type) {
      case 'Receipt': return 'Customer (Debtor)';
      case 'Payment': return 'Cash/Bank';
      case 'Sales': return 'Sales Account';
      case 'Purchase': return 'Supplier (Creditor)';
      case 'Journal': return 'Ledger B';
      case 'Credit Note': return 'Customer (Debtor)';
      case 'Debit Note': return 'Purchase Return';
      case 'Contra': return 'Bank';
      default: return 'Ledger B';
    }
  }
}
