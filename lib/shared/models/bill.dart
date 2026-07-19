import '../../core/database/db_helper.dart';
import '../../core/database/database_init.dart';

class BillItem {
  final int? id;
  final int? billId;
  final int? itemId;
  final String name;
  final double qty;
  final double rate;
  final double discount;
  final double gstRate;
  final double gstAmount;
  final double total;

  BillItem({
    this.id,
    this.billId,
    this.itemId,
    required this.name,
    this.qty = 1,
    this.rate = 0,
    this.discount = 0,
    this.gstRate = 0,
    this.gstAmount = 0,
    this.total = 0,
  });

  factory BillItem.fromMap(Map<String, dynamic> m) => BillItem(
        id: m['id'] as int?,
        billId: m['bill_id'] as int?,
        itemId: m['item_id'] as int?,
        name: (m['name'] ?? '') as String,
        qty: (m['qty'] as num?)?.toDouble() ?? 1,
        rate: (m['rate'] as num?)?.toDouble() ?? 0,
        discount: (m['discount'] as num?)?.toDouble() ?? 0,
        gstRate: (m['gst_rate'] as num?)?.toDouble() ?? 0,
        gstAmount: (m['gst_amount'] as num?)?.toDouble() ?? 0,
        total: (m['total'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (billId != null) 'bill_id': billId,
        if (itemId != null) 'item_id': itemId,
        'name': name,
        'qty': qty,
        'rate': rate,
        'discount': discount,
        'gst_rate': gstRate,
        'gst_amount': gstAmount,
        'total': total,
      };
}

class Bill {
  final int? id;
  final String billNumber;
  final String billDate;
  final int? customerId;
  final String customerName;
  final String customerPhone;
  final String customerGstin;
  final String customerAddress;
  final double subtotal;
  final double totalDiscount;
  final double totalGst;
  final double roundOff;
  final double grandTotal;
  final String paymentMode;
  final String paymentStatus;
  final double paidAmount;
  final double balanceDue;
  final String notes;
  final String termsConditions;
  final String templateName;
  final List<BillItem> items;
  final String? createdAt;
  final String? updatedAt;

  Bill({
    this.id,
    required this.billNumber,
    required this.billDate,
    this.customerId,
    this.customerName = '',
    this.customerPhone = '',
    this.customerGstin = '',
    this.customerAddress = '',
    this.subtotal = 0,
    this.totalDiscount = 0,
    this.totalGst = 0,
    this.roundOff = 0,
    this.grandTotal = 0,
    this.paymentMode = 'Cash',
    this.paymentStatus = 'unpaid',
    this.paidAmount = 0,
    this.balanceDue = 0,
    this.notes = '',
    this.termsConditions = '',
    this.templateName = 'default',
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Bill.fromMap(Map<String, dynamic> m, [List<BillItem> items = const []]) =>
      Bill(
        id: m['id'] as int?,
        billNumber: (m['bill_number'] ?? '') as String,
        billDate: (m['bill_date'] ?? '') as String,
        customerId: m['customer_id'] as int?,
        customerName: (m['customer_name'] ?? '') as String,
        customerPhone: (m['customer_phone'] ?? '') as String,
        customerGstin: (m['customer_gstin'] ?? '') as String,
        customerAddress: (m['customer_address'] ?? '') as String,
        subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
        totalDiscount: (m['total_discount'] as num?)?.toDouble() ?? 0,
        totalGst: (m['total_gst'] as num?)?.toDouble() ?? 0,
        roundOff: (m['round_off'] as num?)?.toDouble() ?? 0,
        grandTotal: (m['grand_total'] as num?)?.toDouble() ?? 0,
        paymentMode: (m['payment_mode'] ?? 'Cash') as String,
        paymentStatus: (m['payment_status'] ?? 'unpaid') as String,
        paidAmount: (m['paid_amount'] as num?)?.toDouble() ?? 0,
        balanceDue: (m['balance_due'] as num?)?.toDouble() ?? 0,
        notes: (m['notes'] ?? '') as String,
        termsConditions: (m['terms_conditions'] ?? '') as String,
        templateName: (m['template_name'] ?? 'default') as String,
        items: items,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'bill_number': billNumber,
        'bill_date': billDate,
        if (customerId != null) 'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_gstin': customerGstin,
        'customer_address': customerAddress,
        'subtotal': subtotal,
        'total_discount': totalDiscount,
        'total_gst': totalGst,
        'round_off': roundOff,
        'grand_total': grandTotal,
        'payment_mode': paymentMode,
        'payment_status': paymentStatus,
        'paid_amount': paidAmount,
        'balance_due': balanceDue,
        'notes': notes,
        'terms_conditions': termsConditions,
        'template_name': templateName,
      };
}

class BillRepository {
  static const _bills = 'bills';
  static const _items = 'bill_items';

  static Future<String> _nextBillNumber() async {
    final now = DateTime.now();
    final year = now.year;
    final prefixRow = await DbHelper.first('settings',
        where: 'key = ?', whereArgs: ['invoice_prefix']);
    final prefix = prefixRow?['value'] as String? ?? 'INV';
    final counterRow = await DbHelper.first('settings',
        where: 'key = ?', whereArgs: ['invoice_counter']);
    int counter = int.tryParse(counterRow?['value'] as String? ?? '0') ?? 0;
    counter += 1;
    await DbHelper.update(
      'settings',
      {'value': counter.toString()},
      where: 'key = ?',
      whereArgs: ['invoice_counter'],
    );
    return '$prefix-$year-${counter.toString().padLeft(4, '0')}';
  }

  static Future<int> create(Bill bill) async {
    final db = await DatabaseInit.database;
    final now = DateTime.now().toIso8601String();
    final number = bill.billNumber.isEmpty
        ? await _nextBillNumber()
        : bill.billNumber;
    final billId = await db.insert(_bills, {
      ...bill.toMap(),
      'bill_number': number,
      'created_at': now,
      'updated_at': now,
    });
    for (final it in bill.items) {
      await db.insert(_items, {...it.toMap(), 'bill_id': billId});
    }
    return billId;
  }

  static Future<List<Bill>> all({String? q, int? limit}) async {
    final rows = await DbHelper.query(_bills,
        where: q == null || q.isEmpty
            ? null
            : 'bill_number LIKE ? OR customer_name LIKE ?',
        whereArgs: q == null || q.isEmpty ? null : ['%$q%', '%$q%'],
        orderBy: 'id DESC',
        limit: limit);
    final out = <Bill>[];
    for (final r in rows) {
      final items = await DbHelper.query(_items,
          where: 'bill_id = ?', whereArgs: [r['id']]);
      out.add(Bill.fromMap(r, items.map(BillItem.fromMap).toList()));
    }
    return out;
  }

  static Future<Bill?> get(int id) async {
    final m = await DbHelper.first(_bills, where: 'id = ?', whereArgs: [id]);
    if (m == null) return null;
    final items = await DbHelper.query(_items,
        where: 'bill_id = ?', whereArgs: [id]);
    return Bill.fromMap(m, items.map(BillItem.fromMap).toList());
  }

  static Future<int> delete(int id) async {
    final db = await DatabaseInit.database;
    await db.delete(_items, where: 'bill_id = ?', whereArgs: [id]);
    return db.delete(_bills, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> todayCount() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return DbHelper.count(_bills,
        where: "bill_date LIKE ?", whereArgs: ['$today%']);
  }

  static Future<double> todayTotal() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await DbHelper.rawQuery(
        'SELECT COALESCE(SUM(grand_total),0) AS s FROM $_bills WHERE bill_date LIKE ?',
        ['$today%']);
    return (rows.first['s'] as num?)?.toDouble() ?? 0;
  }
}
