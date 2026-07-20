import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

class _Employee {
  final int? id;
  final String name;
  final String phone;
  final String role;
  final double basicSalary;
  final double hra;
  final double allowances;
  final String joinDate;
  final bool active;

  _Employee({
    this.id,
    required this.name,
    this.phone = '',
    this.role = 'Staff',
    this.basicSalary = 0,
    this.hra = 0,
    this.allowances = 0,
    this.joinDate = '',
    this.active = true,
  });

  double get gross => basicSalary + hra + allowances;

  factory _Employee.fromMap(Map<String, dynamic> m) => _Employee(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        role: (m['role'] ?? 'Staff') as String,
        basicSalary: (m['basic_salary'] as num?)?.toDouble() ?? 0,
        hra: (m['hra'] as num?)?.toDouble() ?? 0,
        allowances: (m['allowances'] as num?)?.toDouble() ?? 0,
        joinDate: (m['join_date'] ?? '') as String,
        active: (m['active'] ?? 1) == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'basic_salary': basicSalary,
        'hra': hra,
        'allowances': allowances,
        'join_date': joinDate,
        'active': active ? 1 : 0,
      };
}

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});
  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  List<_Employee> _employees = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ensureTable();
    _load();
  }

  Future<void> _ensureTable() async {
    final db = await DbHelper.rawExecute('''
      CREATE TABLE IF NOT EXISTS employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT, role TEXT,
        basic_salary REAL DEFAULT 0,
        hra REAL DEFAULT 0,
        allowances REAL DEFAULT 0,
        join_date TEXT,
        active INTEGER DEFAULT 1,
        created_at TEXT
      )
    ''');
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await DbHelper.query('employees', orderBy: 'name COLLATE NOCASE ASC');
    _employees = rows.map(_Employee.fromMap).toList();
    setState(() => _loading = false);
  }

  Future<void> _upsert(_Employee e) async {
    final map = e.toMap();
    if (e.id == null) {
      map['created_at'] = DateTime.now().toIso8601String();
      await DbHelper.insert('employees', map);
    } else {
      await DbHelper.update('employees', map, where: 'id = ?', whereArgs: [e.id]);
    }
    _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.delete('employees', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final totalPayroll = _employees.fold(0.0, (s, e) => s + e.gross);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_employees.length} Employees',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Monthly Payroll: ${GstService.formatMoney(totalPayroll)}',
                            style: const TextStyle(color: Colors.purple)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _showForm(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Employee'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                    ? Center(
                        child: Text('No employees yet',
                            style: TextStyle(color: Colors.grey.shade600)),
                      )
                    : ListView.separated(
                        itemCount: _employees.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final e = _employees[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade50,
                              child: Text(e.name.isNotEmpty
                                  ? e.name[0].toUpperCase()
                                  : '?'),
                            ),
                            title: Text(e.name),
                            subtitle: Text(
                                '${e.role} • ${e.phone.isEmpty ? "No phone" : e.phone} • Joined ${e.joinDate.isEmpty ? "-" : e.joinDate.substring(0, 10)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(GstService.formatMoney(e.gross),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple)),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      _showForm(context, employee: e);
                                    } else if (v == 'delete') {
                                      _delete(e.id!);
                                    } else if (v == 'payslip') {
                                      _showPayslip(context, e);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'payslip',
                                        child: Text('Generate Payslip')),
                                    PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
                                    PopupMenuItem(
                                        value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, {_Employee? employee}) {
    final name = TextEditingController(text: employee?.name ?? '');
    final phone = TextEditingController(text: employee?.phone ?? '');
    final role = TextEditingController(text: employee?.role ?? 'Staff');
    final basic = TextEditingController(
        text: (employee?.basicSalary ?? 0).toStringAsFixed(0));
    final hra = TextEditingController(
        text: (employee?.hra ?? 0).toStringAsFixed(0));
    final allow = TextEditingController(
        text: (employee?.allowances ?? 0).toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(employee == null ? 'Add Employee' : 'Edit Employee'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _f('Name *', name),
                _f('Phone', phone),
                _f('Role / Designation', role),
                _f('Basic Salary (₹)', basic, num: true),
                _f('HRA (₹)', hra, num: true),
                _f('Other Allowances (₹)', allow, num: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              _upsert(_Employee(
                id: employee?.id,
                name: name.text.trim(),
                phone: phone.text.trim(),
                role: role.text.trim(),
                basicSalary: double.tryParse(basic.text) ?? 0,
                hra: double.tryParse(hra.text) ?? 0,
                allowances: double.tryParse(allow.text) ?? 0,
                joinDate: employee?.joinDate ?? DateTime.now().toIso8601String(),
                active: employee?.active ?? true,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPayslip(BuildContext context, _Employee e) {
    final epf = e.basicSalary * 0.12;
    final esi = e.gross * 0.0075;
    final net = e.gross - epf - esi;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Payslip — ${e.name}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role: ${e.role}'),
              Text('Period: ${DateTime.now().toString().substring(0, 7)}'),
              const Divider(),
              _r('Basic', e.basicSalary),
              _r('HRA', e.hra),
              _r('Allowances', e.allowances),
              const Divider(),
              _r('Gross', e.gross, bold: true),
              const Divider(),
              _r('EPF (12% basic)', -epf),
              _r('ESI (0.75% gross)', -esi),
              const Divider(),
              _r('Net Pay', net, bold: true, color: Colors.green),
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

  Widget _r(String l, double v, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
            Text(GstService.formatMoney(v.abs()),
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    color: color ?? (v < 0 ? Colors.red : null))),
          ],
        ),
      );

  Widget _f(String label, TextEditingController c, {bool num = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
