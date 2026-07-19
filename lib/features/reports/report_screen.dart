import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  double _totalSales = 0;
  double _totalGst = 0;
  int _totalBills = 0;
  List<Map<String, dynamic>> _topItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final salesRow = await DbHelper.rawQuery(
        "SELECT COALESCE(SUM(grand_total),0) AS s, COALESCE(SUM(total_gst),0) AS g, COUNT(*) AS c FROM bills");
    _totalSales = (salesRow.first['s'] as num?)?.toDouble() ?? 0;
    _totalGst = (salesRow.first['g'] as num?)?.toDouble() ?? 0;
    _totalBills = (salesRow.first['c'] as num?)?.toInt() ?? 0;

    final topRows = await DbHelper.rawQuery('''
      SELECT name, SUM(qty) AS qty, SUM(total) AS amt
      FROM bill_items GROUP BY name ORDER BY amt DESC LIMIT 10
    ''');
    _topItems = topRows;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Reports & Analytics',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _card('Total Sales', GstService.formatMoney(_totalSales),
                Colors.teal, Icons.trending_up),
            _card('Total GST Collected', GstService.formatMoney(_totalGst),
                Colors.amber, Icons.receipt),
            _card('Total Bills', '$_totalBills', Colors.indigo, Icons.receipt_long),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Selling Items',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (_topItems.isEmpty)
                  const Text('No sales data yet')
                else
                  ..._topItems.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 4,
                                child: Text(r['name'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500))),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    'Qty: ${(r['qty'] as num?)?.toDouble().toStringAsFixed(0)}')),
                            Expanded(
                                flex: 2,
                                child: Text(GstService.formatMoney(
                                    (r['amt'] as num?)?.toDouble() ?? 0),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal))),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
