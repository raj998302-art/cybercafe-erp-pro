import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// Advanced Reports hub (Phase 8 — Reports & Analytics Engine).
/// Provides all Tally-style + GST + sales + inventory + customer + expense reports.
class AdvancedReportsScreen extends StatefulWidget {
  const AdvancedReportsScreen({super.key});
  @override
  State<AdvancedReportsScreen> createState() => _AdvancedReportsScreenState();
}

class _AdvancedReportsScreenState extends State<AdvancedReportsScreen> {
  String _selected = 'sales_summary';
  Map<String, dynamic> _data = {};
  bool _loading = false;

  static const _reports = [
    ('sales_summary', 'Sales Summary', Icons.trending_up, Colors.teal),
    ('gst_summary', 'GST Collected Summary', Icons.receipt, Colors.amber),
    ('top_customers', 'Top Customers', Icons.people, Colors.indigo),
    ('top_items', 'Top Selling Items', Icons.inventory_2, Colors.deepOrange),
    ('profit_loss', 'Profit & Loss', Icons.account_balance, Colors.green),
    ('expense_summary', 'Expense Summary', Icons.money_off, Colors.red),
    ('day_book', 'Day Book (All Vouchers)', Icons.book, Colors.purple),
    ('trial_balance', 'Trial Balance', Icons.balance, Colors.blue),
    ('customer_balances', 'Customer Balances', Icons.person, Colors.brown),
    ('monthly_sales', 'Monthly Sales Trend', Icons.bar_chart, Colors.cyan),
    ('bill_status', 'Bill Payment Status', Icons.payment, Colors.pink),
    ('inventory_valuation', 'Inventory Valuation', Icons.warehouse, Colors.orange),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = <String, dynamic>{};
    switch (_selected) {
      case 'sales_summary':
        final r = await DbHelper.rawQuery(
            'SELECT COUNT(*) AS count, COALESCE(SUM(grand_total),0) AS sales, COALESCE(SUM(total_gst),0) AS gst, COALESCE(SUM(total_discount),0) AS disc FROM bills');
        data.addAll(r.first);
        break;
      case 'gst_summary':
        final r = await DbHelper.rawQuery(
            'SELECT COALESCE(SUM(subtotal-total_discount),0) AS taxable, COALESCE(SUM(total_gst),0) AS gst, COALESCE(SUM(grand_total),0) AS total FROM bills');
        data.addAll(r.first);
        break;
      case 'top_customers':
        data['rows'] = await DbHelper.rawQuery(
            'SELECT customer_name, COUNT(*) AS bills, SUM(grand_total) AS total FROM bills WHERE customer_name != "" GROUP BY customer_name ORDER BY total DESC LIMIT 10');
        break;
      case 'top_items':
        data['rows'] = await DbHelper.rawQuery(
            'SELECT name, SUM(qty) AS qty, SUM(total) AS amount FROM bill_items GROUP BY name ORDER BY amount DESC LIMIT 10');
        break;
      case 'profit_loss':
        // Revenue = subtotal - discount (excludes GST, which is a liability not income)
        final sales = await DbHelper.rawQuery(
            'SELECT COALESCE(SUM(subtotal - total_discount),0) AS v FROM bills');
        final exp = await DbHelper.rawQuery(
            'SELECT COALESCE(SUM(amount),0) AS v FROM expenses');
        data['sales'] = (sales.first['v'] as num?)?.toDouble() ?? 0;
        data['expenses'] = (exp.first['v'] as num?)?.toDouble() ?? 0;
        data['profit'] = data['sales'] - data['expenses'];
        break;
      case 'expense_summary':
        data['rows'] = await DbHelper.rawQuery(
            'SELECT category, COUNT(*) AS count, SUM(amount) AS total FROM expenses GROUP BY category ORDER BY total DESC');
        break;
      case 'day_book':
        data['rows'] = await DbHelper.query('vouchers', orderBy: 'date DESC', limit: 50);
        break;
      case 'trial_balance':
        data['rows'] = await DbHelper.query('ledgers');
        break;
      case 'customer_balances':
        data['rows'] = await DbHelper.rawQuery(
            'SELECT c.name, COALESCE(SUM(b.grand_total - b.paid_amount),0) AS balance FROM customers c LEFT JOIN bills b ON b.customer_id = c.id GROUP BY c.id ORDER BY balance DESC');
        break;
      case 'monthly_sales':
        data['rows'] = await DbHelper.rawQuery(
            "SELECT strftime('%Y-%m', bill_date) AS month, COUNT(*) AS bills, SUM(grand_total) AS sales FROM bills GROUP BY month ORDER BY month DESC LIMIT 12");
        break;
      case 'bill_status':
        final r = await DbHelper.rawQuery(
            'SELECT payment_status, COUNT(*) AS count, SUM(grand_total) AS total FROM bills GROUP BY payment_status');
        data['rows'] = r;
        break;
      case 'inventory_valuation':
        data['rows'] = await DbHelper.rawQuery(
            'SELECT name, stock_qty, price, (stock_qty*price) AS value FROM items WHERE stock_qty > 0 ORDER BY value DESC');
        break;
    }
    _data = data;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report selector
          SizedBox(
            width: 260,
            child: Card(
              child: ListView(
                children: _reports
                    .map((r) => ListTile(
                          leading: Icon(r.$3, color: r.$4),
                          title: Text(r.$2,
                              style: TextStyle(
                                  fontWeight: _selected == r.$1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selected == r.$1 ? r.$4 : null)),
                          selected: _selected == r.$1,
                          onTap: () {
                            setState(() => _selected = r.$1);
                            _load();
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Report content
          Expanded(
            child: Card(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _renderReport(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderReport() {
    final reportName =
        _reports.firstWhere((r) => r.$1 == _selected).$2;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(reportName,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Generated on ${DateTime.now().toIso8601String().substring(0, 19)}',
            style: const TextStyle(color: Colors.grey)),
        const Divider(),
        const SizedBox(height: 8),
        ..._buildContent(),
      ],
    );
  }

  List<Widget> _buildContent() {
    switch (_selected) {
      case 'sales_summary':
        return [
          _kv('Total Bills', '${_data['count'] ?? 0}'),
          _kv('Total Sales', GstService.formatMoney(
              (_data['sales'] as num?)?.toDouble() ?? 0)),
          _kv('GST Collected', GstService.formatMoney(
              (_data['gst'] as num?)?.toDouble() ?? 0)),
          _kv('Discounts Given', GstService.formatMoney(
              (_data['disc'] as num?)?.toDouble() ?? 0)),
        ];
      case 'gst_summary':
        return [
          _kv('Total Taxable Value', GstService.formatMoney(
              (_data['taxable'] as num?)?.toDouble() ?? 0)),
          _kv('Total GST', GstService.formatMoney(
              (_data['gst'] as num?)?.toDouble() ?? 0)),
          _kv('Total Invoice Value', GstService.formatMoney(
              (_data['total'] as num?)?.toDouble() ?? 0)),
        ];
      case 'profit_loss':
        return [
          _kv('Total Sales', GstService.formatMoney(
              (_data['sales'] as num?)?.toDouble() ?? 0)),
          _kv('Total Expenses', GstService.formatMoney(
              (_data['expenses'] as num?)?.toDouble() ?? 0)),
          const Divider(),
          _kv('Net Profit', GstService.formatMoney(
              (_data['profit'] as num?)?.toDouble() ?? 0),
              color: ((_data['profit'] as num?)?.toDouble() ?? 0) >= 0
                  ? Colors.green
                  : Colors.red),
        ];
      case 'bill_status':
        final rows = (_data['rows'] as List?) ?? [];
        return [
          for (final r in rows)
            _kv((r['payment_status'] as String?)?.toUpperCase() ?? '',
                '${r['count']} bills • ${GstService.formatMoney((r['total'] as num?)?.toDouble() ?? 0)}'),
        ];
      case 'day_book':
        final rows = (_data['rows'] as List?) ?? [];
        if (rows.isEmpty) return [const Text('No vouchers')];
        return [
          for (final r in rows)
            ListTile(
              title: Text('${r['voucher_type']} • ${r['voucher_number']}'),
              subtitle: Text('${(r['date'] as String?)?.substring(0, 10) ?? ""} • ${r['narration'] ?? ""}'),
              trailing: Text(GstService.formatMoney(
                  (r['amount'] as num?)?.toDouble() ?? 0)),
            ),
        ];
      case 'trial_balance':
        final rows = (_data['rows'] as List?) ?? [];
        if (rows.isEmpty) return [const Text('No ledgers')];
        double totalD = 0, totalC = 0;
        for (final r in rows) {
          if ((r['balance_type'] ?? 'debit') == 'debit') {
            totalD += (r['opening_balance'] as num?)?.toDouble() ?? 0;
          } else {
            totalC += (r['opening_balance'] as num?)?.toDouble() ?? 0;
          }
        }
        return [
          for (final r in rows)
            _kv(r['name'] as String? ?? '',
                '${GstService.formatMoney((r['opening_balance'] as num?)?.toDouble() ?? 0)} (${r['balance_type']})'),
          const Divider(),
          _kv('Total Debit', GstService.formatMoney(totalD)),
          _kv('Total Credit', GstService.formatMoney(totalC)),
        ];
      default:
        final rows = (_data['rows'] as List?) ?? [];
        if (rows.isEmpty) return [const Text('No data available')];
        return [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${r.values.take(1).first ?? "-"}')),
                  ...r.values.skip(1).map((v) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('$v'),
                      )),
                ],
              ),
            ),
        ];
    }
  }

  Widget _kv(String k, String v, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: Colors.grey)),
            Text(v,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color)),
          ],
        ),
      );
}
