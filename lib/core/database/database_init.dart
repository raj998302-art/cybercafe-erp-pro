import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Initializes the local SQLite database used for offline-first storage.
/// On Windows desktop, sqflite_ffi is required.
class DatabaseInit {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<void> initialize() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await database;
  }

  static Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'cybercafe_erp.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Company / settings
    batch.execute('''
      CREATE TABLE company (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gstin TEXT, pan TEXT,
        address_line1 TEXT, address_line2 TEXT,
        city TEXT, state TEXT, pincode TEXT,
        phone TEXT, email TEXT, logo TEXT,
        bank_name TEXT, account_name TEXT, account_number TEXT,
        ifsc TEXT, branch TEXT,
        terms_conditions TEXT, signature TEXT,
        updated_at TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Customers
    batch.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT, email TEXT, gstin TEXT,
        address TEXT, opening_balance REAL DEFAULT 0,
        balance_type TEXT DEFAULT 'debit',
        tags TEXT, notes TEXT,
        created_at TEXT, updated_at TEXT
      )
    ''');

    // Suppliers
    batch.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT, email TEXT, gstin TEXT,
        address TEXT, opening_balance REAL DEFAULT 0,
        balance_type TEXT DEFAULT 'credit',
        notes TEXT,
        created_at TEXT, updated_at TEXT
      )
    ''');

    // Items / Services
    batch.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        short_name TEXT,
        category TEXT,
        unit TEXT,
        price REAL DEFAULT 0,
        gst_rate REAL DEFAULT 0,
        hsn_code TEXT, sac_code TEXT,
        stock_qty REAL DEFAULT 0,
        min_stock REAL DEFAULT 0,
        is_service INTEGER DEFAULT 1,
        active INTEGER DEFAULT 1,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT, updated_at TEXT
      )
    ''');

    // Bills (invoices)
    batch.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_number TEXT NOT NULL UNIQUE,
        bill_date TEXT NOT NULL,
        customer_id INTEGER,
        customer_name TEXT, customer_phone TEXT,
        customer_gstin TEXT, customer_address TEXT,
        subtotal REAL, total_discount REAL,
        total_gst REAL, round_off REAL,
        grand_total REAL,
        payment_mode TEXT,
        payment_status TEXT DEFAULT 'unpaid',
        paid_amount REAL DEFAULT 0,
        balance_due REAL DEFAULT 0,
        notes TEXT, terms_conditions TEXT,
        template_name TEXT,
        created_at TEXT, updated_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers(id)
      )
    ''');

    // Bill line items
    batch.execute('''
      CREATE TABLE bill_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_id INTEGER NOT NULL,
        item_id INTEGER,
        name TEXT, qty REAL, rate REAL,
        discount REAL DEFAULT 0,
        gst_rate REAL DEFAULT 0,
        gst_amount REAL DEFAULT 0,
        total REAL,
        FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE
      )
    ''');

    // Expenses
    batch.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        category TEXT, amount REAL,
        payment_mode TEXT, description TEXT,
        created_at TEXT
      )
    ''');

    // Vouchers (Tally-style double entry)
    batch.execute('''
      CREATE TABLE vouchers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucher_type TEXT NOT NULL,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        narration TEXT,
        amount REAL,
        created_at TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE voucher_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucher_id INTEGER NOT NULL,
        ledger TEXT, debit REAL DEFAULT 0,
        credit REAL DEFAULT 0, narration TEXT,
        FOREIGN KEY (voucher_id) REFERENCES vouchers(id) ON DELETE CASCADE
      )
    ''');

    // Ledgers (chart of accounts)
    batch.execute('''
      CREATE TABLE ledgers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        group_name TEXT,
        opening_balance REAL DEFAULT 0,
        balance_type TEXT DEFAULT 'debit',
        gstin TEXT, phone TEXT, address TEXT,
        linked_customer_id INTEGER,
        linked_supplier_id INTEGER,
        created_at TEXT
      )
    ''');

    // Audit log
    batch.execute('''
      CREATE TABLE audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT, entity TEXT, entity_id INTEGER,
        details TEXT, user_id INTEGER, timestamp TEXT
      )
    ''');

    await batch.commit(noResult: true);

    // Seed default settings
    await db.insert('settings', {'key': 'currency', 'value': 'INR'});
    await db.insert('settings', {'key': 'invoice_prefix', 'value': 'INV'});
    await db.insert('settings', {'key': 'invoice_counter', 'value': '0'});
    await db.insert('settings', {'key': 'theme', 'value': 'system'});
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // Future migrations go here.
  }
}
