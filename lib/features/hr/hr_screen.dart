import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// Phase 9 — HR module: Attendance, Leave Management, Salary Processing, Statutory Compliance.
class HrScreen extends StatefulWidget {
  const HrScreen({super.key});
  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen>
    with TickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _ensureTables();
  }

  Future<void> _ensureTables() async {
    for (final sql in [
      "CREATE TABLE IF NOT EXISTS employees (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, role TEXT, basic_salary REAL DEFAULT 0, hra REAL DEFAULT 0, allowances REAL DEFAULT 0, join_date TEXT, active INTEGER DEFAULT 1, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS attendance (id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER, date TEXT, status TEXT DEFAULT 'present', in_time TEXT, out_time TEXT, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS leaves (id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER, from_date TEXT, to_date TEXT, type TEXT, reason TEXT, status TEXT DEFAULT 'pending', created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS salary_runs (id INTEGER PRIMARY KEY AUTOINCREMENT, month TEXT, employee_id INTEGER, gross REAL, epf REAL, esi REAL, pt REAL, net REAL, status TEXT DEFAULT 'processed', created_at TEXT)",
    ]) { try { await DbHelper.rawExecute(sql); } catch (_) {} }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR — Attendance, Leave, Salary'),
        bottom: TabBar(controller: _tab, isScrollable: true, tabs: const [
          Tab(text: 'Attendance'), Tab(text: 'Leaves'),
          Tab(text: 'Salary Processing'), Tab(text: 'Statutory'),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [
        _attendanceTab(), _leaveTab(), _salaryTab(), _statutoryTab(),
      ]),
    );
  }

  Widget _attendanceTab() => _AttTab();
  Widget _leaveTab() => _LeaveTab();
  Widget _salaryTab() => _SalaryTab();
  Widget _statutoryTab() => _StatutoryTab();
}

class _AttTab extends StatefulWidget {
  @override
  State<_AttTab> createState() => _AttTabState();
}

class _AttTabState extends State<_AttTab> {
  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _emps = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    _emps = await DbHelper.query('employees', where: 'active = 1');
    _rows = await DbHelper.query('attendance', orderBy: 'date DESC', limit: 100);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _markAttendance, child: const Icon(Icons.check)),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text('Today: ${DateTime.now().toString().substring(0, 10)} • ${_rows.where((r) => r['status'] == 'present').length} present', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Expanded(child: _rows.isEmpty ? const Center(child: Text('No attendance records')) : ListView.separated(
            itemCount: _rows.length, separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = _rows[i];
              final emp = _emps.where((e) => e['id'] == r['employee_id']).firstOrNull;
              return ListTile(
                leading: Icon(Icons.check_circle, color: r['status'] == 'present' ? Colors.green : Colors.red),
                title: Text(emp?['name'] ?? 'Employee #${r['employee_id']}'),
                subtitle: Text('${r['date']?.toString().substring(0, 10) ?? ""} • ${r['status']} • In: ${r['in_time'] ?? "-"} Out: ${r['out_time'] ?? "-"}'),
              );
            },
          )),
        ],
      ),
    );
  }

  void _markAttendance() {
    String? empId;
    String status = 'present';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('Mark Attendance'),
      content: SizedBox(width: 350, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: empId, decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()),
          items: _emps.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['name']))).toList(),
          onChanged: (v) => setS(() => empId = v)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: status, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
          items: const ['present', 'absent', 'half-day', 'leave'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setS(() => status = v ?? 'present')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          if (empId == null) return;
          await DbHelper.insert('attendance', {'employee_id': empId, 'date': DateTime.now().toIso8601String(), 'status': status, 'in_time': DateTime.now().toIso8601String().substring(11, 19), 'out_time': '', 'created_at': DateTime.now().toIso8601String()});
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('Save')),
      ],
    )));
  }
}

class _LeaveTab extends StatefulWidget {
  @override
  State<_LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends State<_LeaveTab> {
  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _emps = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    _emps = await DbHelper.query('employees');
    _rows = await DbHelper.query('leaves', orderBy: 'from_date DESC');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _apply, child: const Icon(Icons.add)),
      body: _rows.isEmpty ? const Center(child: Text('No leave applications')) : ListView.separated(
        itemCount: _rows.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final r = _rows[i];
          final emp = _emps.where((e) => e['id'] == r['employee_id']).firstOrNull;
          final color = r['status'] == 'approved' ? Colors.green : r['status'] == 'rejected' ? Colors.red : Colors.orange;
          return ListTile(
            leading: Icon(Icons.event_busy, color: color),
            title: Text(emp?['name'] ?? 'Employee #${r['employee_id']}'),
            subtitle: Text('${r['from_date']?.toString().substring(0, 10) ?? ""} to ${r['to_date']?.toString().substring(0, 10) ?? ""} • ${r['type']} • ${r['reason']}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Chip(label: Text(r['status']), backgroundColor: color.withOpacity(0.2)),
              PopupMenuButton<String>(onSelected: (v) async { await DbHelper.update('leaves', {'status': v}, where: 'id = ?', whereArgs: [r['id']]); _load(); },
                itemBuilder: (_) => const [PopupMenuItem(value: 'approved', child: Text('Approve')), PopupMenuItem(value: 'rejected', child: Text('Reject'))]),
            ]),
          );
        },
      ),
    );
  }

  void _apply() {
    final from = TextEditingController();
    final to = TextEditingController();
    final reason = TextEditingController();
    String? empId;
    String type = 'casual';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('Apply Leave'),
      content: SizedBox(width: 350, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: empId, decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()),
          items: _emps.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['name']))).toList(),
          onChanged: (v) => setS(() => empId = v)),
        const SizedBox(height: 12),
        TextField(controller: from, decoration: const InputDecoration(labelText: 'From (YYYY-MM-DD)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: to, decoration: const InputDecoration(labelText: 'To (YYYY-MM-DD)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
          items: const ['casual', 'sick', 'earned', 'unpaid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setS(() => type = v ?? 'casual')),
        const SizedBox(height: 8),
        TextField(controller: reason, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          if (empId == null) return;
          await DbHelper.insert('leaves', {'employee_id': empId, 'from_date': from.text, 'to_date': to.text, 'type': type, 'reason': reason.text, 'status': 'pending', 'created_at': DateTime.now().toIso8601String()});
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('Apply')),
      ],
    )));
  }
}

class _SalaryTab extends StatefulWidget {
  @override
  State<_SalaryTab> createState() => _SalaryTabState();
}

class _SalaryTabState extends State<_SalaryTab> {
  List<Map<String, dynamic>> _emps = [];
  List<Map<String, dynamic>> _runs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    _emps = await DbHelper.query('employees', where: 'active = 1');
    _runs = await DbHelper.query('salary_runs', orderBy: 'month DESC');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final month = DateTime.now().toString().substring(0, 7);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(onPressed: _process, icon: const Icon(Icons.payments), label: Text('Process $month')),
      body: Column(children: [
        Card(margin: const EdgeInsets.all(16), child: Padding(padding: const EdgeInsets.all(16), child: Text('Salary for $month • ${_emps.length} active employees', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
        Expanded(child: _runs.isEmpty ? const Center(child: Text('No salary runs yet')) : ListView.separated(
          itemCount: _runs.length, separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final r = _runs[i];
            final emp = _emps.where((e) => e['id'] == r['employee_id']).firstOrNull;
            return ListTile(
              leading: const Icon(Icons.payments, color: Colors.green),
              title: Text('${emp?['name'] ?? "Employee #${r['employee_id']}"} • ${r['month']}'),
              subtitle: Text('Gross: ${GstService.formatMoney((r['gross'] as num?)?.toDouble() ?? 0)} • Net: ${GstService.formatMoney((r['net'] as num?)?.toDouble() ?? 0)}'),
            );
          },
        )),
      ]),
    );
  }

  Future<void> _process() async {
    final month = DateTime.now().toString().substring(0, 7);
    for (final e in _emps) {
      final gross = ((e['basic_salary'] as num?)?.toDouble() ?? 0) + ((e['hra'] as num?)?.toDouble() ?? 0) + ((e['allowances'] as num?)?.toDouble() ?? 0);
      final epf = (e['basic_salary'] as num?)?.toDouble() != null ? (e['basic_salary'] as num).toDouble() * 0.12 : 0.0;
      final esi = gross < 21000 ? gross * 0.0075 : 0.0;
      final pt = gross > 15000 ? 200.0 : 0.0;
      final net = gross - epf - esi - pt;
      await DbHelper.insert('salary_runs', {'month': month, 'employee_id': e['id'], 'gross': gross, 'epf': epf, 'esi': esi, 'pt': pt, 'net': net, 'status': 'processed', 'created_at': DateTime.now().toIso8601String()});
    }
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Salary processed for ${_emps.length} employees'))); _load(); }
  }
}

class _StatutoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(24), children: [
      const Text('Statutory Compliance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      _card(context, 'EPF (Employee Provident Fund)', '12% of basic salary. Employer contributes 12%.', 'Generate ECR', Icons.savings, Colors.blue),
      _card(context, 'ESI (Employee State Insurance)', '0.75% from employee, 3.25% from employer. For salary < ₹21,000.', 'Generate ESI', Icons.health_and_safety, Colors.green),
      _card(context, 'Professional Tax (PT)', 'State-specific. ₹200/month for salary > ₹15,000 in Maharashtra.', 'Generate PT', Icons.account_balance, Colors.purple),
      _card(context, 'TDS on Salary', 'Deduct TDS as per income tax slab. Form 24Q quarterly.', 'Generate Form 24Q', Icons.receipt, Colors.orange),
      _card(context, 'Form 16', 'Annual TDS certificate for employees.', 'Generate Form 16', Icons.description, Colors.red),
    ]);
  }

  Widget _card(BuildContext context, String title, String subtitle, String btn, IconData icon, Color color) => Card(child: ListTile(
    leading: Icon(icon, color: color, size: 40),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle),
    trailing: FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title: Use Advanced Reports for data')); }, child: Text(btn)),
  ));
}
