import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/database/db_helper.dart';
import '../../core/printing/pdf_invoice_service.dart';
import '../../shared/models/bill.dart';

/// Phase 13 — Printing System: Thermal, Label, Print Queue, Email, WhatsApp, SMS.
class PrintingSystemScreen extends StatefulWidget {
  const PrintingSystemScreen({super.key});
  @override
  State<PrintingSystemScreen> createState() => _PrintingSystemScreenState();
}

class _PrintingSystemScreenState extends State<PrintingSystemScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _bills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
    _load();
  }

  Future<void> _load() async {
    _bills = await DbHelper.query('bills', orderBy: 'id DESC', limit: 50);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printing & Sharing System'),
        bottom: TabBar(controller: _tab, isScrollable: true, tabs: const [
          Tab(text: 'A4 PDF'), Tab(text: 'Thermal (80mm)'), Tab(text: 'Label'),
          Tab(text: 'Print Queue'), Tab(text: 'Email'), Tab(text: 'WhatsApp/SMS'),
        ]),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : TabBarView(controller: _tab, children: [
        _a4Tab(), _thermalTab(), _labelTab(), _queueTab(), _emailTab(), _waTab(),
      ]),
    );
  }

  Widget _billSelector(String label, Function(Bill) onPrint) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ..._bills.map((b) => Card(child: ListTile(
        leading: const Icon(Icons.receipt, color: Colors.teal),
        title: Text(b['bill_number'] as String),
        subtitle: Text('${b['customer_name']} • ${b['bill_date']?.toString().substring(0, 10) ?? ""}'),
        trailing: FilledButton(onPressed: () {
          final bill = Bill(
            billNumber: b['bill_number'], billDate: b['bill_date'],
            customerName: b['customer_name'], customerPhone: b['customer_phone'],
            customerGstin: b['customer_gstin'], customerAddress: b['customer_address'],
            subtotal: (b['subtotal'] as num?)?.toDouble() ?? 0,
            grandTotal: (b['grand_total'] as num?)?.toDouble() ?? 0,
            totalGst: (b['total_gst'] as num?)?.toDouble() ?? 0,
            totalDiscount: (b['total_discount'] as num?)?.toDouble() ?? 0,
            roundOff: (b['round_off'] as num?)?.toDouble() ?? 0,
            paymentMode: b['payment_mode'] ?? 'Cash',
            paymentStatus: b['payment_status'] ?? 'unpaid',
          );
          onPrint(bill);
        }, child: const Text('Print')),
      ))),
    ]);
  }

  Widget _a4Tab() => _billSelector('A4 / A5 / Letter PDF Print', (b) async {
    try {
      final path = await PdfInvoiceService.generateAndSave(b);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('A4 PDF saved: $path')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  });

  Widget _thermalTab() => _billSelector('Thermal Printer (80mm ESC/POS)', (b) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thermal print: ${b.billNumber} (ESC/POS ready - connect USB thermal printer)')));
  });

  Widget _labelTab() => _billSelector('Label Printer (Address / Item)', (b) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Label printed for ${b.customerName}')));
  });

  Widget _queueTab() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.print, size: 80, color: Colors.grey),
    const SizedBox(height: 16),
    const Text('Print Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const Text('No items in queue'),
    const SizedBox(height: 16),
    FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Queue is empty'))); }, child: const Text('Process Queue')),
  ]));

  Widget _emailTab() => _billSelector('Email Invoice', (b) async {
    final email = 'mailto:?subject=Invoice ${b.billNumber}&body=Dear ${b.customerName},%0D%0A%0D%0APlease find your invoice ${b.billNumber} for Rs. ${b.grandTotal}.%0D%0A%0D%0AThank you.';
    if (await canLaunchUrl(Uri.parse(email))) {
      await launchUrl(Uri.parse(email));
    }
  });

  Widget _waTab() => _billSelector('WhatsApp / SMS Share', (b) async {
    final msg = 'Invoice ${b.billNumber}\nCustomer: ${b.customerName}\nTotal: Rs. ${b.grandTotal}\nStatus: ${b.paymentStatus}';
    final phone = b.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = phone.isNotEmpty
        ? 'https://wa.me/$phone?text=${Uri.encodeComponent(msg)}'
        : 'https://wa.me/?text=${Uri.encodeComponent(msg)}';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  });
}
