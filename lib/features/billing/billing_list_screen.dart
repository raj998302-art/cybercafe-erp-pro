import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/services/gst_service.dart';
import '../../core/printing/pdf_invoice_service.dart';
import '../../shared/models/bill.dart';

class BillingListScreen extends StatefulWidget {
  const BillingListScreen({super.key});
  @override
  State<BillingListScreen> createState() => _BillingListScreenState();
}

class _BillingListScreenState extends State<BillingListScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BillProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    labelText: 'Search bills (number / customer)',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => p.load(q: v),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.go('/billing/new'),
                icon: const Icon(Icons.add),
                label: const Text('New Bill'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: p.loading && p.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : p.items.isEmpty
                    ? _emptyState(context)
                    : ListView.separated(
                        itemCount: p.items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final b = p.items[i];
                          return _billTile(context, b, p);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _billTile(BuildContext context, Bill b, BillProvider p) {
    final statusColor = b.paymentStatus == 'paid'
        ? Colors.green
        : b.paymentStatus == 'partial'
            ? Colors.orange
            : Colors.red;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal.shade50,
        child: const Icon(Icons.receipt, color: Colors.teal),
      ),
      title: Text(b.billNumber,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
          '${b.customerName.isEmpty ? "Walk-in customer" : b.customerName} • ${b.billDate.substring(0, 10)}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(GstService.formatMoney(b.grandTotal),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(b.paymentStatus.toUpperCase(),
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      onTap: () => _showBillOptions(context, b, p),
    );
  }

  void _showBillOptions(BuildContext context, Bill b, BillProvider p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Details'),
                onTap: () => _showDetails(context, b)),
            ListTile(
                leading: const Icon(Icons.print),
                title: const Text('Print / PDF'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final path = await PdfInvoiceService.generateAndSave(b);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF saved: $path')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF error: $e')));
                    }
                  }
                }),
            ListTile(
                leading: const Icon(Icons.share),
                title: const Text('WhatsApp Share'),
                onTap: () {
                  Navigator.pop(ctx);
                  _shareWhatsApp(b);
                }),
            ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title: Text('Delete',
                    style: TextStyle(color: Colors.red.shade700)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: const Text('Delete Bill?'),
                      content: Text(
                          'Delete ${b.billNumber}? This cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(d, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(d, true),
                            child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await p.delete(b.id!);
                  }
                }),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Bill b) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(b.billNumber),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${b.customerName.isEmpty ? "Walk-in" : b.customerName}'),
              Text('Date: ${b.billDate}'),
              const Divider(),
              ...b.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                                '${i.name} × ${i.qty.toStringAsFixed(i.qty % 1 == 0 ? 0 : 2)}')),
                        Text(GstService.formatMoney(i.total)),
                      ],
                    ),
                  )),
              const Divider(),
              _row('Subtotal', GstService.formatMoney(b.subtotal)),
              _row('Discount', '- ${GstService.formatMoney(b.totalDiscount)}'),
              _row('GST', GstService.formatMoney(b.totalGst)),
              _row('Round Off', GstService.formatMoney(b.roundOff)),
              const Divider(),
              _row('Grand Total', GstService.formatMoney(b.grandTotal),
                  bold: true),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
            Text(value,
                style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          ],
        ),
      );

  void _shareWhatsApp(Bill b) async {
    final msg = '*${b.billNumber}*\n'
        'Date: ${b.billDate.substring(0, 10)}\n'
        'Customer: ${b.customerName.isEmpty ? "Walk-in" : b.customerName}\n'
        '${b.items.map((i) => '${i.name} × ${i.qty.toStringAsFixed(i.qty % 1 == 0 ? 0 : 2)} = ${GstService.formatMoney(i.total)}').join('\n')}\n'
        '\n*Total: ${GstService.formatMoney(b.grandTotal)}*\n'
        'Status: ${b.paymentStatus.toUpperCase()}';
    final phone = b.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = phone.isNotEmpty
        ? 'https://wa.me/$phone?text=${Uri.encodeComponent(msg)}'
        : 'https://wa.me/?text=${Uri.encodeComponent(msg)}';
    // Generate PDF first, then share
    try {
      final path = await PdfInvoiceService.generateAndSave(b);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved: $path. Opening WhatsApp...')));
      }
    } catch (_) {}
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp')));
      }
    }
  }

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No bills yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Create your first GST invoice in one click.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/billing/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Bill'),
            ),
          ],
        ),
      );
}
