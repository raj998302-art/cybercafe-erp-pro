import '../../core/database/db_helper.dart';

class Customer {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String gstin;
  final String address;
  final String state;
  final double openingBalance;
  final String balanceType; // debit / credit
  final String tags;
  final String notes;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.gstin = '',
    this.address = '',
    this.state = '',
    this.openingBalance = 0,
    this.balanceType = 'debit',
    this.tags = '',
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromMap(Map<String, dynamic> m) => Customer(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        gstin: (m['gstin'] ?? '') as String,
        address: (m['address'] ?? '') as String,
        state: (m['state'] ?? '') as String,
        openingBalance: (m['opening_balance'] as num?)?.toDouble() ?? 0,
        balanceType: (m['balance_type'] ?? 'debit') as String,
        tags: (m['tags'] ?? '') as String,
        notes: (m['notes'] ?? '') as String,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'gstin': gstin,
        'address': address,
        'state': state,
        'opening_balance': openingBalance,
        'balance_type': balanceType,
        'tags': tags,
        'notes': notes,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? gstin,
    String? address,
    String? state,
    double? openingBalance,
    String? balanceType,
    String? tags,
    String? notes,
  }) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        gstin: gstin ?? this.gstin,
        address: address ?? this.address,
        state: state ?? this.state,
        openingBalance: openingBalance ?? this.openingBalance,
        balanceType: balanceType ?? this.balanceType,
        tags: tags ?? this.tags,
        notes: notes ?? this.notes,
      );
}

class CustomerRepository {
  static const _table = 'customers';

  static Future<int> upsert(Customer c) async {
    final now = DateTime.now().toIso8601String();
    final map = {...c.toMap(), 'updated_at': now};
    if (c.id == null) {
      map['created_at'] = now;
      return DbHelper.insert(_table, map);
    }
    return DbHelper.update(_table, map, where: 'id = ?', whereArgs: [c.id]);
  }

  static Future<List<Customer>> all({String? q}) async {
    final rows = q == null || q.isEmpty
        ? await DbHelper.query(_table, orderBy: 'name COLLATE NOCASE ASC')
        : await DbHelper.rawQuery(
            "SELECT * FROM $_table WHERE name LIKE ? OR phone LIKE ? ORDER BY name COLLATE NOCASE ASC",
            ['%$q%', '%$q%'],
          );
    return rows.map(Customer.fromMap).toList();
  }

  static Future<Customer?> get(int id) async {
    final m = await DbHelper.first(_table, where: 'id = ?', whereArgs: [id]);
    return m == null ? null : Customer.fromMap(m);
  }

  static Future<int> delete(int id) =>
      DbHelper.delete(_table, where: 'id = ?', whereArgs: [id]);
}
