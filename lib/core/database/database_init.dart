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
      version: 2,
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
        address TEXT, state TEXT DEFAULT '',
        opening_balance REAL DEFAULT 0,
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

    // ---- Phase 3: Tally advanced accounting ----
    batch.execute('''CREATE TABLE cost_centers (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, parent_id INTEGER, created_at TEXT)''');
    batch.execute('''CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT, ledger_id INTEGER, period TEXT, amount REAL, actual REAL DEFAULT 0, created_at TEXT)''');
    batch.execute('''CREATE TABLE bank_reconciliation (
        id INTEGER PRIMARY KEY AUTOINCREMENT, ledger_id INTEGER, txn_date TEXT, amount REAL, type TEXT, cheque_no TEXT, cleared INTEGER DEFAULT 0, cleared_date TEXT)''');
    batch.execute('''CREATE TABLE currencies (
        id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT, name TEXT, symbol TEXT, rate REAL DEFAULT 1)''');
    batch.execute('''CREATE TABLE fixed_assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, purchase_date TEXT, cost REAL, salvage REAL, useful_life INTEGER, method TEXT DEFAULT 'slm', depreciation REAL DEFAULT 0, created_at TEXT)''');

    // ---- Phase 5: Inventory advanced ----
    batch.execute('''CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, parent_id INTEGER, type TEXT DEFAULT 'item')''');
    batch.execute('''CREATE TABLE batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER, batch_no TEXT, expiry_date TEXT, qty REAL, created_at TEXT)''');
    batch.execute('''CREATE TABLE godowns (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, created_at TEXT)''');
    batch.execute('''CREATE TABLE stock_transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER, from_godown INTEGER, to_godown INTEGER, qty REAL, date TEXT, created_at TEXT)''');
    batch.execute('''CREATE TABLE bom (
        id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, component_id INTEGER, qty REAL, created_at TEXT)''');
    batch.execute('''CREATE TABLE purchase_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT, po_number TEXT, date TEXT, supplier_id INTEGER, items TEXT, total REAL, status TEXT DEFAULT 'pending', created_at TEXT)''');

    // ---- Phase 7: GST compliance ----
    batch.execute('''CREATE TABLE tds_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, party TEXT, pan TEXT, amount REAL, tds_rate REAL, tds_amount REAL, section TEXT, created_at TEXT)''');
    batch.execute('''CREATE TABLE tcs_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, party TEXT, amount REAL, tcs_rate REAL, tcs_amount REAL, created_at TEXT)''');

    // ---- Phase 9: Payroll ----
    batch.execute('''CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, role TEXT, basic_salary REAL DEFAULT 0, hra REAL DEFAULT 0, allowances REAL DEFAULT 0, join_date TEXT, active INTEGER DEFAULT 1, created_at TEXT)''');
    batch.execute('''CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER, date TEXT, status TEXT DEFAULT 'present', in_time TEXT, out_time TEXT, created_at TEXT)''');
    batch.execute('''CREATE TABLE leaves (
        id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER, from_date TEXT, to_date TEXT, type TEXT, reason TEXT, status TEXT DEFAULT 'pending', created_at TEXT)''');
    batch.execute('''CREATE TABLE salary_runs (
        id INTEGER PRIMARY KEY AUTOINCREMENT, month TEXT, employee_id INTEGER, gross REAL, epf REAL, esi REAL, pt REAL, net REAL, status TEXT DEFAULT 'processed', created_at TEXT)''');

    // ---- Phase 14: Advanced ----
    batch.execute('''CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, number TEXT, fuel_type TEXT, odometer INTEGER DEFAULT 0, created_at TEXT)''');
    batch.execute('''CREATE TABLE fuel_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT, vehicle_id INTEGER, date TEXT, liters REAL, amount REAL, odometer INTEGER, station TEXT, created_at TEXT)''');
    batch.execute('''CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, entity_type TEXT, entity_id INTEGER, file_path TEXT, description TEXT, created_at TEXT)''');

    // ---- Tables created by feature screens at runtime (also in _onCreate for fresh installs) ----
    batch.execute('''CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT,
        remind_date TEXT NOT NULL, type TEXT DEFAULT 'custom', done INTEGER DEFAULT 0, created_at TEXT)''');
    batch.execute('''CREATE TABLE IF NOT EXISTS cheques (
        id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, cheque_no TEXT NOT NULL,
        bank TEXT, amount REAL, issue_date TEXT, clearance_date TEXT, party_name TEXT,
        status TEXT DEFAULT 'pending', notes TEXT, created_at TEXT)''');
    batch.execute('''CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT,
        color TEXT DEFAULT '#FFF9C4', created_at TEXT, updated_at TEXT)''');
    batch.execute('''CREATE TABLE IF NOT EXISTS companies_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, gstin TEXT, pan TEXT,
        address TEXT, state TEXT, phone TEXT, email TEXT, is_active INTEGER DEFAULT 0, created_at TEXT)''');
    batch.execute('''CREATE TABLE IF NOT EXISTS recycle_bin (
        id INTEGER PRIMARY KEY AUTOINCREMENT, source_table TEXT NOT NULL,
        record_id INTEGER NOT NULL, record_data TEXT NOT NULL, deleted_at TEXT NOT NULL)''');

    await batch.commit(noResult: true);

    // Seed default settings
    await db.insert('settings', {'key': 'currency', 'value': 'INR'});
    await db.insert('settings', {'key': 'invoice_prefix', 'value': 'INV'});
    await db.insert('settings', {'key': 'invoice_counter', 'value': '0'});
    await db.insert('settings', {'key': 'theme', 'value': 'system'});
    await db.insert('settings', {'key': 'app_pin', 'value': '1234'});
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // Add state column to customers if missing (v1 -> v2)
    if (oldV < 2) {
      try {
        await db.execute("ALTER TABLE customers ADD COLUMN state TEXT DEFAULT ''");
      } catch (_) {}
      // Create all new tables that were added in v2
      for (final sql in [
        "CREATE TABLE IF NOT EXISTS cost_centers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, parent_id INTEGER, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS budgets (id INTEGER PRIMARY KEY AUTOINCREMENT, ledger_id INTEGER, period TEXT, amount REAL, actual REAL DEFAULT 0, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS bank_reconciliation (id INTEGER PRIMARY KEY AUTOINCREMENT, ledger_id INTEGER, txn_date TEXT, amount REAL, type TEXT, cheque_no TEXT, cleared INTEGER DEFAULT 0, cleared_date TEXT)",
        "CREATE TABLE IF NOT EXISTS currencies (id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT, name TEXT, symbol TEXT, rate REAL DEFAULT 1)",
        "CREATE TABLE IF NOT EXISTS fixed_assets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, purchase_date TEXT, cost REAL, salvage REAL, useful_life INTEGER, method TEXT DEFAULT 'slm', depreciation REAL DEFAULT 0, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, parent_id INTEGER, type TEXT DEFAULT 'item')",
        "CREATE TABLE IF NOT EXISTS batches (id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER, batch_no TEXT, expiry_date TEXT, qty REAL, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS godowns (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS stock_transfers (id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER, from_godown INTEGER, to_godown INTEGER, qty REAL, date TEXT, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS bom (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, component_id INTEGER, qty REAL, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS purchase_orders (id INTEGER PRIMARY KEY AUTOINCREMENT, po_number TEXT, date TEXT, supplier_id INTEGER, items TEXT, total REAL, status TEXT DEFAULT 'pending', created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS tds_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, party TEXT, pan TEXT, amount REAL, tds_rate REAL, tds_amount REAL, section TEXT, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS tcs_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, party TEXT, amount REAL, tcs_rate REAL, tcs_amount REAL, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS employees (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, role TEXT, basic_salary REAL DEFAULT 0, hra REAL DEFAULT 0, allowances REAL DEFAULT 0, join_date TEXT, active INTEGER DEFAULT 1, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS attendance (id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER, date TEXT, status TEXT DEFAULT 'present', in_time TEXT, out_time TEXT, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS leaves (id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER, from_date TEXT, to_date TEXT, type TEXT, reason TEXT, status TEXT DEFAULT 'pending', created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS salary_runs (id INTEGER PRIMARY KEY AUTOINCREMENT, month TEXT, employee_id INTEGER, gross REAL, epf REAL, esi REAL, pt REAL, net REAL, status TEXT DEFAULT 'processed', created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS vehicles (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, number TEXT, fuel_type TEXT, odometer INTEGER DEFAULT 0, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS fuel_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, vehicle_id INTEGER, date TEXT, liters REAL, amount REAL, odometer INTEGER, station TEXT, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS documents (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, entity_type TEXT, entity_id INTEGER, file_path TEXT, description TEXT, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS reminders (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, remind_date TEXT NOT NULL, type TEXT DEFAULT 'custom', done INTEGER DEFAULT 0, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS cheques (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, cheque_no TEXT NOT NULL, bank TEXT, amount REAL, issue_date TEXT, clearance_date TEXT, party_name TEXT, status TEXT DEFAULT 'pending', notes TEXT, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, color TEXT DEFAULT '#FFF9C4', created_at TEXT, updated_at TEXT)",
        "CREATE TABLE IF NOT EXISTS companies_list (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, gstin TEXT, pan TEXT, address TEXT, state TEXT, phone TEXT, email TEXT, is_active INTEGER DEFAULT 0, created_at TEXT)",
        "CREATE TABLE IF NOT EXISTS recycle_bin (id INTEGER PRIMARY KEY AUTOINCREMENT, source_table TEXT NOT NULL, record_id INTEGER NOT NULL, record_data TEXT NOT NULL, deleted_at TEXT NOT NULL)",
      ]) {
        try {
          await db.execute(sql);
        } catch (_) {}
      }
      try { await db.insert('settings', {'key': 'app_pin', 'value': '1234'}); } catch (_) {}
    }
  }
}
