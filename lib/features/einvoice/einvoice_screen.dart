import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// E-Invoice & E-Way Bill screen (Phase 7 — GST Compliance).
/// Generates IRN-style JSON for e-invoicing and E-Way Bill data.
/// Note: This is an offline simulation. For real IRP integration,
/// add API credentials in settings and connect to the IRP portal.
class EInvoiceScreen extends StatefulWidget {
  const EInvoiceScreen({super.key});
  @override
  State<EInvoiceScreen> createState() => _EInvoiceScreenState();
}

class _EInvoiceScreenState extends State<EInvoiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _bills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _bills = await DbHelper.query('bills',
        where: 'customer_gstin IS NOT NULL AND customer_gstin != ""',
        orderBy: 'bill_date DESC');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Invoice & E-Way Bill'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'E-Invoice (IRN)'), Tab(text: 'E-Way Bill')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [_einvoiceTab(), _ewaybillTab()],
            ),
    );
  }

  Widget _einvoiceTab() {
    if (_bills.isEmpty) {
      return const Center(
          child: Text('No B2B bills (with customer GSTIN) found.\n'
              'E-Invoice is mandatory for B2B sales.',
              textAlign: TextAlign.center));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bills.length,
      itemBuilder: (context, i) {
        final b = _bills[i];
        final irn = _generateIrn(b);
        return Card(
          child: ExpansionTile(
            leading: const CircleAvatar(
                backgroundColor: Colors.teal, child: Icon(Icons.receipt)),
            title: Text(b['bill_number'] as String),
            subtitle: Text(
                '${b['customer_name']} • ${GstService.formatMoney((b['grand_total'] as num?)?.toDouble() ?? 0)}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('IRN (64-char hash)', irn),
                    _kv('Ack No.', 'ACK${(i + 1).toString().padLeft(8, '0')}'),
                    _kv('Ack Date',
                        DateTime.now().toIso8601String().substring(0, 19)),
                    _kv('Status', 'Generated (Offline)'),
                    const SizedBox(height: 8),
                    const Text('E-Invoice JSON:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey.shade100,
                      child: SelectableText(
                        const JsonEncoder.withIndent('  ')
                            .convert(_buildEInvoiceJson(b, irn)),
                        style: const TextStyle(
                            fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ewaybillTab() {
    if (_bills.isEmpty) {
      return const Center(child: Text('No bills available for E-Way Bill'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bills.length,
      itemBuilder: (context, i) {
        final b = _bills[i];
        final ewbNo = 'EWB${DateTime.now().year}${(i + 1).toString().padLeft(10, '0')}';
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
                backgroundColor: Colors.orange, child: Icon(Icons.local_shipping)),
            title: Text(b['bill_number'] as String),
            subtitle: Text(
                'EWB No: $ewbNo\n${b['customer_name']} • ${GstService.formatMoney((b['grand_total'] as num?)?.toDouble() ?? 0)}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEwbDetails(b, ewbNo),
          ),
        );
      },
    );
  }

  void _showEwbDetails(Map<String, dynamic> b, String ewbNo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('E-Way Bill: $ewbNo'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv('EWB Number', ewbNo),
              _kv('Generated Date',
                  DateTime.now().toIso8601String().substring(0, 19)),
              _kv('Valid Until',
                  DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 19)),
              _kv('Supply Type', 'Outward'),
              _kv('Document Type', 'Tax Invoice'),
              _kv('Document No', b['bill_number'] as String),
              _kv('From State', 'Maharashtra'),
              _kv('To State', 'Maharashtra'),
              _kv('Transport Mode', 'By Road'),
              _kv('Vehicle No', 'MH12AB1234'),
              _kv('Total Value',
                  GstService.formatMoney((b['grand_total'] as num?)?.toDouble() ?? 0)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Print EWB'),
          ),
        ],
      ),
    );
  }

  String _generateIrn(Map<String, dynamic> b) {
    // Simulated 64-char IRN hash (real IRN comes from IRP portal)
    final src = '${b['bill_number']}${b['bill_date']}${b['customer_gstin'] ?? ""}${b['grand_total']}';
    final bytes = src.codeUnits;
    final sb = StringBuffer();
    for (var i = 0; i < 64; i++) {
      sb.write((bytes[i % bytes.length] + i).toRadixString(16).substring(0, 1));
    }
    return sb.toString().toLowerCase();
  }

  Map<String, dynamic> _buildEInvoiceJson(Map<String, dynamic> b, String irn) => {
        'Irn': irn,
        'AckNo': 1,
        'AckDt': DateTime.now().toIso8601String(),
        'Version': '1.1',
        'TranDtls': {'TaxSch': 'GST', 'SupTyp': 'B2B', 'RegRev': 'N'},
        'DocDtls': {
          'Typ': 'INV',
          'No': b['bill_number'],
          'Dt': (b['bill_date'] as String?)?.substring(0, 10),
        },
        'SellerDtls': {
          'Gstin': '27XXXXXXXXXX1Z5',
          'LglNm': 'My Cyber Cafe',
          'Addr1': 'Shop Address',
          'Loc': 'Mumbai',
          'Pin': 400001,
          'Stcd': '27',
        },
        'BuyerDtls': {
          'Gstin': b['customer_gstin'] ?? '',
          'LglNm': b['customer_name'] ?? '',
          'Addr1': b['customer_address'] ?? '',
          'Loc': 'Mumbai',
          'Pin': 400001,
          'Stcd': '27',
        },
        'ValDtls': {
          'AssVal': (b['subtotal'] as num?)?.toDouble() ?? 0,
          'CgstVal': (b['total_gst'] as num?)?.toDouble() ?? 0,
          'SgstVal': 0,
          'IgstVal': 0,
          'TotInvVal': (b['grand_total'] as num?)?.toDouble() ?? 0,
        },
      };

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 140,
                child: Text(k,
                    style: const TextStyle(color: Colors.grey, fontSize: 13))),
            Expanded(child: SelectableText(v, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}
