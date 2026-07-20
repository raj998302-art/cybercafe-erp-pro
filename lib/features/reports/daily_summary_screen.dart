import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// Uncle's Prompt Module 6 — Daily Summary (End of Day, 1 screen).
/// Shows today's sales, bills, GST collected, payment mode breakdown.
class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});
  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  List<Map<String, dynamic>> _bills = [];
  double _totalSales = 0;
  double _totalGst = 0;
  double _totalDiscount = 0;
  Map<String, double> _modeBreakup = {};
  int _paidCount = 0;
  int _unpaidCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Reset accumulators before loading (prevents double-count on refresh)
    _totalSales = 0;
    _totalGst = 0;
    _totalDiscount = 0;
    _modeBreakup = {};
    _paidCount = 0;
    _unpaidCount = 0;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _bills = await DbHelper.query('bills', where: 'bill_date LIKE ?', whereArgs: ['$today%'], orderBy: 'id DESC');
    for (final b in _bills) {
      _totalSales += (b['grand_total'] as num?)?.toDouble() ?? 0;
      _totalGst += (b['total_gst'] as num?)?.toDouble() ?? 0;
      _totalDiscount += (b['total_discount'] as num?)?.toDouble() ?? 0;
      final mode = b['payment_mode'] as String? ?? 'Cash';
      _modeBreakup[mode] = (_modeBreakup[mode] ?? 0) + ((b['grand_total'] as num?)?.toDouble() ?? 0);
      if (b['payment_status'] == 'paid') {
        _paidCount++;
      } else {
        _unpaidCount++;
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: Text("Today's Report — ${DateTime.now().toString().substring(0, 10)}")),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        // Summary cards
        GridView.count(crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5, children: [
          _stat('Total Sales', GstService.formatMoney(_totalSales), Colors.teal, Icons.trending_up),
          _stat('Bills Today', '${_bills.length}', Colors.indigo, Icons.receipt_long),
          _stat('GST Collected', GstService.formatMoney(_totalGst), Colors.amber, Icons.receipt),
          _stat('Discounts', GstService.formatMoney(_totalDiscount), Colors.red, Icons.local_offer),
        ]),
        const SizedBox(height: 24),
        // Payment status
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Payment Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statusChip('Paid', _paidCount, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _statusChip('Unpaid/Partial', _unpaidCount, Colors.red)),
          ]),
        ]))),
        const SizedBox(height: 16),
        // Payment mode breakup
        if (_modeBreakup.isNotEmpty) ...[
          const Text('Payment Mode Breakup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._modeBreakup.entries.map((e) => Card(child: ListTile(
            leading: Icon(_modeIcon(e.key), color: Colors.teal),
            title: Text(e.key),
            trailing: Text(GstService.formatMoney(e.value), style: const TextStyle(fontWeight: FontWeight.bold)),
          ))),
          const SizedBox(height: 16),
        ],
        // Bills list
        const Text('Today\'s Bills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_bills.isEmpty)
          const Card(child: ListTile(leading: Icon(Icons.inbox), title: Text('No bills created today')))
        else
          ..._bills.map((b) => Card(child: ListTile(
            leading: const Icon(Icons.receipt, color: Colors.teal),
            title: Text(b['bill_number'] as String),
            subtitle: Text('${b['customer_name'] ?? "Walk-in"} • ${b['payment_mode']} • ${b['payment_status']}'),
            trailing: Text(GstService.formatMoney((b['grand_total'] as num?)?.toDouble() ?? 0), style: const TextStyle(fontWeight: FontWeight.bold)),
          ))),
      ]),
    );
  }

  Widget _stat(String label, String value, Color color, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, color: color, size: 28),
    const Spacer(),
    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 12)),
  ])));

  Widget _statusChip(String label, int count, Color color) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))), child: Column(children: [
    Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(color: color)),
  ]));

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'Cash': return Icons.money;
      case 'UPI': return Icons.qr_code;
      case 'Card': return Icons.credit_card;
      case 'Cheque': return Icons.account_balance;
      default: return Icons.payment;
    }
  }
}
