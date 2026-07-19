import '../../core/database/db_helper.dart';
import '../../core/config/app_config.dart';

class Item {
  final int? id;
  final String name;
  final String shortName;
  final String category;
  final String unit;
  final double price;
  final double gstRate;
  final String hsnCode;
  final String sacCode;
  final double stockQty;
  final double minStock;
  final bool isService;
  final bool active;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  Item({
    this.id,
    required this.name,
    this.shortName = '',
    this.category = 'Custom',
    this.unit = 'Flat',
    this.price = 0,
    this.gstRate = 0,
    this.hsnCode = '',
    this.sacCode = '',
    this.stockQty = 0,
    this.minStock = 0,
    this.isService = true,
    this.active = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromMap(Map<String, dynamic> m) => Item(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        shortName: (m['short_name'] ?? '') as String,
        category: (m['category'] ?? 'Custom') as String,
        unit: (m['unit'] ?? 'Flat') as String,
        price: (m['price'] as num?)?.toDouble() ?? 0,
        gstRate: (m['gst_rate'] as num?)?.toDouble() ?? 0,
        hsnCode: (m['hsn_code'] ?? '') as String,
        sacCode: (m['sac_code'] ?? '') as String,
        stockQty: (m['stock_qty'] as num?)?.toDouble() ?? 0,
        minStock: (m['min_stock'] as num?)?.toDouble() ?? 0,
        isService: (m['is_service'] ?? 1) == 1,
        active: (m['active'] ?? 1) == 1,
        sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'short_name': shortName,
        'category': category,
        'unit': unit,
        'price': price,
        'gst_rate': gstRate,
        'hsn_code': hsnCode,
        'sac_code': sacCode,
        'stock_qty': stockQty,
        'min_stock': minStock,
        'is_service': isService ? 1 : 0,
        'active': active ? 1 : 0,
        'sort_order': sortOrder,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };
}

/// Default cyber cafe items pre-loaded on first run.
const List<Map<String, dynamic>> defaultCyberCafeItems = [
  {'name': 'Color Print A4', 'short_name': 'CLR A4', 'category': 'Print', 'unit': 'Per Page', 'price': 10.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'B&W Print A4', 'short_name': 'BW A4', 'category': 'Print', 'unit': 'Per Page', 'price': 2.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Color Print A3', 'short_name': 'CLR A3', 'category': 'Print', 'unit': 'Per Page', 'price': 20.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'B&W Print A3', 'short_name': 'BW A3', 'category': 'Print', 'unit': 'Per Page', 'price': 5.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Xerox / Photocopy A4', 'short_name': 'XROX', 'category': 'Xerox', 'unit': 'Per Page', 'price': 1.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Xerox Color A4', 'short_name': 'XCLR', 'category': 'Xerox', 'unit': 'Per Page', 'price': 8.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Lamination A4', 'short_name': 'LAM A4', 'category': 'Custom', 'unit': 'Per Piece', 'price': 15.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Lamination A3', 'short_name': 'LAM A3', 'category': 'Custom', 'unit': 'Per Piece', 'price': 25.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Spiral Binding', 'short_name': 'SPBND', 'category': 'Custom', 'unit': 'Per Book', 'price': 30.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Hard Binding', 'short_name': 'HDBND', 'category': 'Custom', 'unit': 'Per Book', 'price': 80.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Passport Photo (set of 4)', 'short_name': 'PP4', 'category': 'Custom', 'unit': 'Per Set', 'price': 50.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Passport Photo (set of 6)', 'short_name': 'PP6', 'category': 'Custom', 'unit': 'Per Set', 'price': 70.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'ID Card Making', 'short_name': 'IDCRD', 'category': 'Custom', 'unit': 'Per Card', 'price': 30.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Scanning (per page)', 'short_name': 'SCAN', 'category': 'Custom', 'unit': 'Per Page', 'price': 5.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Typing (per page)', 'short_name': 'TYPE', 'category': 'Custom', 'unit': 'Per Page', 'price': 15.0, 'gst_rate': 18.0, 'hsn_code': '9989'},
  {'name': 'Computer Rental', 'short_name': 'CMP', 'category': 'Cyber', 'unit': 'Per Hour', 'price': 30.0, 'gst_rate': 18.0, 'hsn_code': '9986'},
  {'name': 'Internet Browsing', 'short_name': 'NET', 'category': 'Cyber', 'unit': 'Per Hour', 'price': 20.0, 'gst_rate': 18.0, 'hsn_code': '9986'},
  {'name': 'Aadhaar New Enrollment', 'short_name': 'ADHR', 'category': 'Govt Service', 'unit': 'Flat', 'price': 50.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Aadhaar Update / Correction', 'short_name': 'ADHU', 'category': 'Govt Service', 'unit': 'Flat', 'price': 50.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'PAN Card Apply', 'short_name': 'PAN', 'category': 'Govt Service', 'unit': 'Flat', 'price': 100.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'PAN Card Correction', 'short_name': 'PANC', 'category': 'Govt Service', 'unit': 'Flat', 'price': 100.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Voter ID Apply', 'short_name': 'VOT', 'category': 'Govt Service', 'unit': 'Flat', 'price': 50.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Income Certificate', 'short_name': 'INC', 'category': 'Govt Service', 'unit': 'Flat', 'price': 100.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Caste Certificate', 'short_name': 'CST', 'category': 'Govt Service', 'unit': 'Flat', 'price': 100.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Domicile Certificate', 'short_name': 'DOM', 'category': 'Govt Service', 'unit': 'Flat', 'price': 100.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Birth Certificate', 'short_name': 'BTH', 'category': 'Govt Service', 'unit': 'Flat', 'price': 80.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Death Certificate', 'short_name': 'DTH', 'category': 'Govt Service', 'unit': 'Flat', 'price': 80.0, 'gst_rate': 0.0, 'hsn_code': '9992'},
  {'name': 'Train Ticket (IRCTC)', 'short_name': 'TRN', 'category': 'Custom', 'unit': 'Per Txn', 'price': 30.0, 'gst_rate': 5.0, 'hsn_code': '9964'},
  {'name': 'Air Ticket', 'short_name': 'AIR', 'category': 'Custom', 'unit': 'Per Txn', 'price': 150.0, 'gst_rate': 5.0, 'hsn_code': '9964'},
  {'name': 'Bus Ticket', 'short_name': 'BUS', 'category': 'Custom', 'unit': 'Per Txn', 'price': 30.0, 'gst_rate': 5.0, 'hsn_code': '9964'},
  {'name': 'Passport Application', 'short_name': 'PSP', 'category': 'Govt Service', 'unit': 'Flat', 'price': 200.0, 'gst_rate': 18.0, 'hsn_code': '9992'},
  {'name': 'Visa Application', 'short_name': 'VISA', 'category': 'Govt Service', 'unit': 'Flat', 'price': 300.0, 'gst_rate': 18.0, 'hsn_code': '9992'},
  {'name': 'Mobile Recharge', 'short_name': 'MOB', 'category': 'Custom', 'unit': 'Per Txn', 'price': 10.0, 'gst_rate': 0.0, 'hsn_code': '9989'},
  {'name': 'DTH Recharge', 'short_name': 'DTH', 'category': 'Custom', 'unit': 'Per Txn', 'price': 10.0, 'gst_rate': 0.0, 'hsn_code': '9989'},
  {'name': 'Electricity Bill', 'short_name': 'ELEC', 'category': 'Custom', 'unit': 'Per Txn', 'price': 20.0, 'gst_rate': 0.0, 'hsn_code': '9989'},
  {'name': 'Gas Bill Payment', 'short_name': 'GAS', 'category': 'Custom', 'unit': 'Per Txn', 'price': 20.0, 'gst_rate': 0.0, 'hsn_code': '9989'},
  {'name': 'Water Bill Payment', 'short_name': 'WTR', 'category': 'Custom', 'unit': 'Per Txn', 'price': 20.0, 'gst_rate': 0.0, 'hsn_code': '9989'},
  {'name': 'GST Registration', 'short_name': 'GSTR', 'category': 'Govt Service', 'unit': 'Flat', 'price': 500.0, 'gst_rate': 18.0, 'hsn_code': '9992'},
  {'name': 'Income Tax Return', 'short_name': 'ITR', 'category': 'Govt Service', 'unit': 'Flat', 'price': 300.0, 'gst_rate': 18.0, 'hsn_code': '9992'},
  {'name': 'Courier / Speed Post', 'short_name': 'CRR', 'category': 'Custom', 'unit': 'Flat', 'price': 50.0, 'gst_rate': 18.0, 'hsn_code': '9968'},
];

class ItemRepository {
  static const _table = 'items';

  static Future<int> upsert(Item i) async {
    final now = DateTime.now().toIso8601String();
    final map = {...i.toMap(), 'updated_at': now};
    if (i.id == null) {
      map['created_at'] = now;
      return DbHelper.insert(_table, map);
    }
    return DbHelper.update(_table, map, where: 'id = ?', whereArgs: [i.id]);
  }

  static Future<List<Item>> all({bool onlyActive = false, String? q}) async {
    final where = StringBuffer();
    final args = <Object?>[];
    if (onlyActive) {
      where.write('active = 1');
    }
    if (q != null && q.isNotEmpty) {
      if (where.isNotEmpty) where.write(' AND ');
      where.write('(name LIKE ? OR short_name LIKE ?)');
      args.addAll(['%$q%', '%$q%']);
    }
    final rows = await DbHelper.query(_table,
        where: where.isEmpty ? null : where.toString(),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'sort_order ASC, name COLLATE NOCASE ASC');
    return rows.map(Item.fromMap).toList();
  }

  static Future<Item?> get(int id) async {
    final m = await DbHelper.first(_table, where: 'id = ?', whereArgs: [id]);
    return m == null ? null : Item.fromMap(m);
  }

  static Future<int> delete(int id) =>
      DbHelper.delete(_table, where: 'id = ?', whereArgs: [id]);

  static Future<void> seedDefaults() async {
    final count = await DbHelper.count(_table);
    if (count > 0) return;
    for (var i = 0; i < defaultCyberCafeItems.length; i++) {
      final d = defaultCyberCafeItems[i];
      await DbHelper.insert(_table, {
        ...d,
        'stock_qty': 0,
        'min_stock': 0,
        'is_service': 1,
        'active': 1,
        'sort_order': i,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
