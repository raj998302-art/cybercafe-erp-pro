import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/gst_service.dart';
import '../../shared/models/bill.dart';

/// PDF invoice generator + print helper (Phase 13 — Printing System).
/// Generates an A4 PDF invoice and saves it to the Windows file system.
class PdfInvoiceService {
  static Future<String> generateAndSave(Bill bill,
      {Map<String, String>? company}) async {
    final pdf = pw.Document();
    final comp = company ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          _header(comp),
          pw.SizedBox(height: 20),
          _invoiceMeta(bill),
          pw.SizedBox(height: 20),
          _parties(bill, comp),
          pw.SizedBox(height: 20),
          _itemsTable(bill, ctx),
          pw.SizedBox(height: 12),
          _totals(bill),
          pw.SizedBox(height: 24),
          _footer(comp, bill),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final outDir = Directory(p.join(dir.path, 'CyberCafeERP', 'Invoices'));
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
    final file = File(p.join(outDir.path, '${bill.billNumber}.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _header(Map<String, String> comp) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(comp['name'] ?? 'My Cyber Cafe',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.teal700)),
            pw.SizedBox(height: 4),
            pw.Text(comp['address'] ?? '', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Phone: ${comp['phone'] ?? '-'}',
                style: const pw.TextStyle(fontSize: 10)),
            if ((comp['gstin'] ?? '').isNotEmpty)
              pw.Text('GSTIN: ${comp['gstin']}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.teal700, width: 2),
          ),
          child: pw.Text('TAX INVOICE',
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal700)),
        ),
      ],
    );
  }

  static pw.Widget _invoiceMeta(Bill bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Invoice No: ${bill.billNumber}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Text('Date: ${bill.billDate.substring(0, 10)}',
            style: const pw.TextStyle(fontSize: 12)),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: bill.paymentStatus == 'paid'
                ? PdfColors.green100
                : PdfColors.red100,
          ),
          child: pw.Text(bill.paymentStatus.toUpperCase(),
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  static pw.Widget _parties(Bill bill, Map<String, String> comp) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To',
                    style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(bill.customerName.isEmpty
                    ? 'Walk-in Customer'
                    : bill.customerName,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (bill.customerAddress.isNotEmpty)
                  pw.Text(bill.customerAddress,
                      style: const pw.TextStyle(fontSize: 10)),
                if (bill.customerPhone.isNotEmpty)
                  pw.Text('Phone: ${bill.customerPhone}',
                      style: const pw.TextStyle(fontSize: 10)),
                if (bill.customerGstin.isNotEmpty)
                  pw.Text('GSTIN: ${bill.customerGstin}',
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Payment',
                    style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Mode: ${bill.paymentMode}'),
                pw.Text('Paid: ${GstService.formatMoney(bill.paidAmount)}'),
                pw.Text('Balance: ${GstService.formatMoney(bill.balanceDue)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _itemsTable(Bill bill, pw.Context ctx) {
    return pw.Table.fromTextArray(
      context: ctx,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
      headerStyle: pw.TextStyle(
          color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(70),
        4: const pw.FixedColumnWidth(50),
        5: const pw.FixedColumnWidth(80),
      },
      headers: ['#', 'Item', 'Qty', 'Rate', 'GST%', 'Amount'],
      data: bill.items.asMap().entries.map((e) {
        final i = e.value;
        return [
          '${e.key + 1}',
          i.name,
          i.qty.toStringAsFixed(i.qty % 1 == 0 ? 0 : 2),
          GstService.formatMoney(i.rate),
          '${i.gstRate}%',
          GstService.formatMoney(i.total),
        ];
      }).toList(),
    );
  }

  static pw.Widget _totals(Bill bill) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 240,
        child: pw.Column(
          children: [
            _t('Subtotal', GstService.formatMoney(bill.subtotal)),
            _t('Discount', '- ${GstService.formatMoney(bill.totalDiscount)}'),
            _t('GST', GstService.formatMoney(bill.totalGst)),
            _t('Round Off', GstService.formatMoney(bill.roundOff)),
            pw.Divider(),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text(GstService.formatMoney(bill.grandTotal),
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal700)),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                'In words: ${AmountInWords.convert(bill.grandTotal)}',
                style: pw.TextStyle(
                    fontSize: 9, fontStyle: pw.FontStyle.italic)),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Padding _t(String l, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(l), pw.Text(v)],
        ),
      );

  static pw.Widget _footer(Map<String, String> comp, Bill bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Terms & Conditions',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(comp['terms'] ?? 'Goods once sold will not be taken back.',
                style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 4),
            pw.Text('Notes: ${bill.notes}',
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('For ${comp['name'] ?? 'Cyber Cafe'}',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 30),
            pw.Text('Authorised Signatory',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }
}
