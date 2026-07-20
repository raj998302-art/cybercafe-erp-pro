import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

class GstScreen extends StatefulWidget {
  const GstScreen({super.key});
  @override
  State<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends State<GstScreen> {
  late String _period;
  late TextEditingController _periodCtrl;
  List<Map<String, dynamic>> _rows = [];
  double _totalTax = 0;
  double _totalValue = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _period = DateTime.now().toIso8601String().substring(0, 7);
    _periodCtrl = TextEditingController(text: _period);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Use LIKE prefix match so Feb/Apr/Jun/Sep/Nov (30-day months) work correctly
    final rows = await DbHelper.rawQuery('''
      SELECT bill_number, bill_date, customer_name, customer_gstin,
             subtotal, total_discount, grand_total, total_gst, payment_status
      FROM bills
      WHERE bill_date LIKE ? || '%'
      ORDER BY bill_date DESC
    ''', [_period]);
    double tax = 0, val = 0;
    for (final r in rows) {
      tax += (r['total_gst'] as num?)?.toDouble() ?? 0;
      // Taxable value = subtotal - discount (excludes GST)
      final sub = (r['subtotal'] as num?)?.toDouble() ?? 0;
      final disc = (r['total_discount'] as num?)?.toDouble() ?? 0;
      val += sub - disc;
    }
    setState(() {
      _rows = rows;
      _totalTax = tax;
      _totalValue = val;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _periodCtrl.dispose();
    super.dispose();
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
              Text('GST Returns',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Period (YYYY-MM)',
                    border: OutlineInputBorder(),
                  ),
                  controller: _periodCtrl,
                  onChanged: (v) {
                    if (v.length == 7) {
                      _period = v;
                      _load();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryCard('Total Taxable Value', GstService.formatMoney(_totalValue),
                  Colors.teal),
              const SizedBox(width: 12),
              _summaryCard('Total GST', GstService.formatMoney(_totalTax),
                  Colors.amber),
              const SizedBox(width: 12),
              _summaryCard('Bills Count', '${_rows.length}', Colors.indigo),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                    ? Center(
                        child: Text('No bills in $_period',
                            style: TextStyle(color: Colors.grey.shade600)))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Bill No')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Customer')),
                              DataColumn(label: Text('GSTIN')),
                              DataColumn(label: Text('Value'), numeric: true),
                              DataColumn(label: Text('GST'), numeric: true),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: _rows
                                .map((r) => DataRow(cells: [
                                      DataCell(Text(r['bill_number'] as String)),
                                      DataCell(Text(
                                          (r['bill_date'] as String).substring(0, 10))),
                                      DataCell(Text(
                                          (r['customer_name'] as String?) ??
                                              'Walk-in')),
                                      DataCell(Text(
                                          (r['customer_gstin'] as String?) ?? '-')),
                                      DataCell(Text(GstService.formatMoney(
                                          (r['grand_total'] as num?)?.toDouble() ??
                                              0))),
                                      DataCell(Text(GstService.formatMoney(
                                          (r['total_gst'] as num?)?.toDouble() ??
                                              0))),
                                      DataCell(Text((r['payment_status'] as String?) ??
                                          '-')),
                                    ]))
                                .toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
