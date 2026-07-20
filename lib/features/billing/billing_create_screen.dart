import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/models/bill.dart';
import '../../shared/models/customer.dart';
import '../../shared/models/item.dart';
import '../../core/services/gst_service.dart';
import '../../core/database/db_helper.dart';
import '../../core/printing/pdf_invoice_service.dart';

class BillingCreateScreen extends StatefulWidget {
  const BillingCreateScreen({super.key});
  @override
  State<BillingCreateScreen> createState() => _BillingCreateScreenState();
}

class _BillingCreateScreenState extends State<BillingCreateScreen> {
  Customer? _customer;
  final _items = <_Line>[];
  String _paymentMode = 'Cash';
  double _paid = 0;
  final _notesCtrl = TextEditingController();
  List<Item> _allItems = [];
  List<Customer> _allCustomers = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _allItems = await ItemRepository.all(onlyActive: true);
    _allCustomers = await CustomerRepository.all();
    if (mounted) setState(() {});
  }

  double get _subtotal =>
      _items.fold(0, (s, l) => s + l.qty * l.rate);
  double get _discount =>
      _items.fold(0, (s, l) => s + l.discount);
  double get _taxable => _subtotal - _discount;
  double get _gst => _items.fold(
      0,
      (s, l) =>
          s + (l.qty * l.rate - l.discount) * l.gstRate / 100);
  double get _grand => _taxable + _gst;
  double get _round => (_grand).roundToDouble() - _grand;
  double get _total => _grand + _round;
  double get _change => _paid > _total ? _paid - _total : 0;

  // GST breakup (intra-state: CGST+SGST, inter-state: IGST)
  // Intra-state when customer state is empty (walk-in) OR matches shop state.
  Map<String, double> get _gstBreakup {
    final customerState = _customer?.state ?? '';
    final shopState = 'Maharashtra'; // default; should come from company settings
    final intraState = customerState.isEmpty ||
        customerState.toLowerCase() == shopState.toLowerCase();
    return GstService.breakup(_taxable, _gst > 0 && _taxable > 0 ? (_gst / _taxable * 100) : 0, intraState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer + payment row
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer & Payment',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Customer?>(
                            value: _customer,
                            decoration: const InputDecoration(
                              labelText: 'Select Customer (or leave for walk-in)',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<Customer?>(
                                value: null,
                                child: Text('Walk-in Customer'),
                              ),
                              ..._allCustomers.map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                        '${c.name}${c.phone.isEmpty ? "" : " • ${c.phone}"}'),
                                  )),
                            ],
                            onChanged: (v) => setState(() => _customer = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          child: DropdownButtonFormField<String>(
                            value: _paymentMode,
                            decoration: const InputDecoration(
                              labelText: 'Payment',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              'Cash', 'UPI', 'Card', 'Net Banking',
                              'Cheque', 'Wallet', 'Credit'
                            ]
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _paymentMode = v ?? 'Cash'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Add item row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickItem,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add Item / Service'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Items table
            Expanded(
              flex: 3,
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'No items added yet.\nTap "Add Item" to start the bill.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final l = _items[i];
                        return ListTile(
                          title: Text(l.name),
                          subtitle: Text(
                              '${GstService.formatMoney(l.rate)} × ${l.qty.toStringAsFixed(l.qty % 1 == 0 ? 0 : 2)} • GST ${l.gstRate}%'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(GstService.formatMoney(l.qty * l.rate),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () =>
                                    setState(() => _items.removeAt(i)),
                              ),
                            ],
                          ),
                          onTap: () => _editQty(i),
                        );
                      },
                    ),
            ),
            const Divider(height: 32),
            // Totals + save
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes',
                                style:
                                    Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TextField(
                                controller: _notesCtrl,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Optional notes for this bill...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: Colors.teal.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _t('Subtotal', GstService.formatMoney(_subtotal)),
                            _t('Discount', '- ${GstService.formatMoney(_discount)}'),
                            _t('GST', GstService.formatMoney(_gst)),
                            _t('Round Off', GstService.formatMoney(_round)),
                            const Divider(),
                            _t('Grand Total', GstService.formatMoney(_total),
                                big: true),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(child: Text('Amount Paid (₹):')),
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      hintText: '0',
                                    ),
                                    onChanged: (v) => setState(() {
                                      _paid = double.tryParse(v) ?? 0;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            if (_paid > 0)
                              _t(_change > 0 ? 'Change' : 'Balance Due',
                                  GstService.formatMoney(_change > 0 ? _change : (_total - _paid)),
                                  big: _change > 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/billing'),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save Bill'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _t(String l, String v, {bool big = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: big
                  ? const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)
                  : null),
          Text(v,
              style: big
                  ? const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)
                  : null),
        ],
      );

  void _pickItem() async {
    final picked = await showDialog<Item>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Item / Service'),
        content: SizedBox(
          width: 500,
          child: ListView(
            shrinkWrap: true,
            children: _allItems
                .map((i) => ListTile(
                      leading: const Icon(Icons.circle, size: 10),
                      title: Text(i.name),
                      subtitle: Text(
                          '${i.category} • ${GstService.formatMoney(i.price)} • GST ${i.gstRate}%'),
                      onTap: () => Navigator.pop(ctx, i),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
    if (picked != null) {
      setState(() {
        _items.add(_Line(
          itemId: picked.id,
          name: picked.name,
          qty: 1,
          rate: picked.price,
          discount: 0,
          gstRate: picked.gstRate,
        ));
      });
    }
  }

  void _editQty(int i) {
    final ctrl = TextEditingController(
        text: _items[i].qty.toStringAsFixed(_items[i].qty % 1 == 0 ? 0 : 2));
    final rateCtrl =
        TextEditingController(text: _items[i].rate.toStringAsFixed(2));
    final discCtrl =
        TextEditingController(text: _items[i].discount.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_items[i].name),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Quantity', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rateCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Rate (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: discCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Discount (₹)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                _items[i] = _items[i].copyWith(
                  qty: double.tryParse(ctrl.text) ?? _items[i].qty,
                  rate: double.tryParse(rateCtrl.text) ?? _items[i].rate,
                  discount:
                      double.tryParse(discCtrl.text) ?? _items[i].discount,
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one item first.')));
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final bill = Bill(
      billNumber: '',
      billDate: now.toIso8601String(),
      customerId: _customer?.id,
      customerName: _customer?.name ?? '',
      customerPhone: _customer?.phone ?? '',
      customerGstin: _customer?.gstin ?? '',
      customerAddress: _customer?.address ?? '',
      subtotal: _subtotal,
      totalDiscount: _discount,
      totalGst: _gst,
      roundOff: _round,
      grandTotal: _total,
      paymentMode: _paymentMode,
      paymentStatus:
          _paid >= _total ? 'paid' : _paid > 0 ? 'partial' : 'unpaid',
      paidAmount: _paid,
      balanceDue: _total - _paid,
      notes: _notesCtrl.text,
      items: _items
          .map((l) => BillItem(
                itemId: l.itemId,
                name: l.name,
                qty: l.qty,
                rate: l.rate,
                discount: l.discount,
                gstRate: l.gstRate,
                gstAmount:
                    (l.qty * l.rate - l.discount) * l.gstRate / 100,
                total: l.qty * l.rate - l.discount,
              ))
          .toList(),
    );
    final id = await context.read<BillProvider>().create(bill);

    // Decrement stock for each item sold
    for (final l in _items) {
      if (l.itemId != null) {
        final item = await ItemRepository.get(l.itemId!);
        if (item != null && !item.isService) {
          await ItemRepository.upsert(item.copyWith(
            stockQty: item.stockQty - l.qty,
          ));
        }
      }
    }

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bill saved! ID #$id')));
      // Offer to print PDF
      _offerPrint(bill);
    }
  }

  void _offerPrint(Bill bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bill Saved!'),
        content: const Text('What would you like to do next?'),
        actions: [
          TextButton(
              onPressed: () { context.go('/billing'); },
              child: const Text('Done')),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final path = await PdfInvoiceService.generateAndSave(bill);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF saved: $path')));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF error: $e')));
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
              context.go('/billing');
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Save PDF'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/billing');
            },
            icon: const Icon(Icons.check),
            label: const Text('New Bill'),
          ),
        ],
      ),
    );
  }
}

class _Line {
  final int? itemId;
  final String name;
  final double qty;
  final double rate;
  final double discount;
  final double gstRate;
  _Line({
    this.itemId,
    required this.name,
    required this.qty,
    required this.rate,
    required this.discount,
    required this.gstRate,
  });
  _Line copyWith({
    int? itemId,
    String? name,
    double? qty,
    double? rate,
    double? discount,
    double? gstRate,
  }) =>
      _Line(
        itemId: itemId ?? this.itemId,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        rate: rate ?? this.rate,
        discount: discount ?? this.discount,
        gstRate: gstRate ?? this.gstRate,
      );
}
