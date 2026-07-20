import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';
import '../../shared/models/customer.dart';

/// Customer detail screen (Phase 6 — CRM extras).
/// Shows: customer dashboard, ledger (Tally-style), statement, loyalty points.
class CustomerDetailScreen extends StatefulWidget {
  final int customerId;
  const CustomerDetailScreen({super.key, required this.customerId});
  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  Customer? _customer;
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _vouchers = [];
  double _totalBilled = 0;
  double _totalPaid = 0;
  double _balance = 0;
  int _loyaltyPoints = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final c = await CustomerRepository.get(widget.customerId);
    if (c == null) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer not found')));
      }
      return;
    }
    _customer = c;
    _bills = await DbHelper.rawQuery(
        'SELECT * FROM bills WHERE customer_id = ? ORDER BY bill_date DESC',
        [widget.customerId]);
    _vouchers = await DbHelper.rawQuery(
        'SELECT * FROM vouchers WHERE narration LIKE ? ORDER BY date DESC',
        ['%${c.name}%']);
    _totalBilled = _bills.fold(
        0.0, (s, b) => s + ((b['grand_total'] as num?)?.toDouble() ?? 0));
    _totalPaid = _bills.fold(
        0.0, (s, b) => s + ((b['paid_amount'] as num?)?.toDouble() ?? 0));
    _balance = _totalBilled - _totalPaid;
    // Loyalty: 1 point per ₹100 spent
    _loyaltyPoints = (_totalBilled / 100).floor();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    // Guard against null customer (e.g., not found / deleted)
    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Not Found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('This customer could not be loaded.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/customers'),
                child: const Text('Back to Customers'),
              ),
            ],
          ),
        ),
      );
    }
    final c = _customer!;
    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Ledger'),
            Tab(text: 'Statement'),
            Tab(text: 'Loyalty'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _dashboardTab(c),
          _ledgerTab(),
          _statementTab(c),
          _loyaltyTab(c),
        ],
      ),
    );
  }

  Widget _dashboardTab(Customer c) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(c.name.isNotEmpty
                            ? c.name[0].toUpperCase()
                            : '?')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          if (c.phone.isNotEmpty) Text('Phone: ${c.phone}'),
                          if (c.gstin.isNotEmpty) Text('GSTIN: ${c.gstin}'),
                          if (c.address.isNotEmpty) Text(c.address),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _stat('Total Billed', GstService.formatMoney(_totalBilled),
                  Colors.teal),
              _stat('Total Paid', GstService.formatMoney(_totalPaid),
                  Colors.green),
              _stat('Balance Due', GstService.formatMoney(_balance),
                  Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt, color: Colors.indigo),
              title: const Text('Total Bills'),
              trailing: Text('${_bills.length}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );

  Widget _ledgerTab() {
    // Tally-style ledger: running balance
    double running = 0;
    final rows = <Map<String, dynamic>>[];
    // Opening balance
    if (_customer != null && _customer!.openingBalance != 0) {
      running = _customer!.openingBalance;
      rows.add({
        'date': 'Opening',
        'particulars': 'To Opening Balance',
        'debit': _customer!.balanceType == 'debit' ? running : 0,
        'credit': _customer!.balanceType == 'credit' ? running : 0,
      });
    }
    for (final b in _bills) {
      final amt = (b['grand_total'] as num?)?.toDouble() ?? 0;
      final paid = (b['paid_amount'] as num?)?.toDouble() ?? 0;
      if (amt > 0) {
        running += amt;
        rows.add({
          'date': (b['bill_date'] as String?)?.substring(0, 10) ?? '',
          'particulars': 'To ${b['bill_number']} (Sales)',
          'debit': amt,
          'credit': 0,
        });
      }
      if (paid > 0) {
        running -= paid;
        rows.add({
          'date': (b['bill_date'] as String?)?.substring(0, 10) ?? '',
          'particulars': 'By ${b['payment_mode']} (Receipt)',
          'debit': 0,
          'credit': paid,
        });
      }
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Customer Ledger (Tally-style)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Particulars')),
                  DataColumn(label: Text('Debit'), numeric: true),
                  DataColumn(label: Text('Credit'), numeric: true),
                ],
                rows: rows
                    .map((r) => DataRow(cells: [
                          DataCell(Text(r['date'] as String)),
                          DataCell(Text(r['particulars'] as String)),
                          DataCell(Text(r['debit'] > 0
                              ? GstService.formatMoney(r['debit'])
                              : '-')),
                          DataCell(Text(r['credit'] > 0
                              ? GstService.formatMoney(r['credit'])
                              : '-')),
                        ]))
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.indigo.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Closing Balance',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(GstService.formatMoney(running),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.indigo)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statementTab(Customer c) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(c.address),
                  const Divider(),
                  const Text('Account Statement',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text(
                      'Period: All transactions to date',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._bills.map((b) => Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt, color: Colors.teal),
                  title: Text(b['bill_number'] as String),
                  subtitle: Text(
                      '${(b['bill_date'] as String?)?.substring(0, 10) ?? ""} • ${b['payment_status']}'),
                  trailing: Text(
                      GstService.formatMoney(
                          (b['grand_total'] as num?)?.toDouble() ?? 0),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
        ],
      );

  Widget _loyaltyTab(Customer c) => Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, size: 80, color: Colors.amber),
                const SizedBox(height: 16),
                Text('$_loyaltyPoints',
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber)),
                const Text('Loyalty Points',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Earned from ${_bills.length} bills (1 pt per ₹100)'),
                const SizedBox(height: 16),
                const Text(
                    'Redeem points for discounts on future bills.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            '$_loyaltyPoints points available to redeem')));
                  },
                  icon: const Icon(Icons.redeem),
                  label: const Text('Redeem Points'),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _stat(String label, String value, Color color) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
}
