import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';

/// Calendar & Reminders screen (Phase 14 — Calendar & Reminders).
/// Shows a monthly calendar with reminders for: GST filing dates,
/// cheque clearance, bill follow-ups, and custom reminders.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _reminders = [];
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ensureTable();
    _selectedDay = _focusedDay;
    _load();
  }

  Future<void> _ensureTable() async {
    await DbHelper.rawExecute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        remind_date TEXT NOT NULL,
        type TEXT DEFAULT 'custom',
        done INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');
  }

  Future<void> _load() async {
    final dateStr = _selectedDay!.toIso8601String().substring(0, 10);
    _reminders = await DbHelper.query('reminders',
        where: 'remind_date LIKE ?', whereArgs: ['$dateStr%']);
    // Auto-generate GST reminders for 11th and 20th of each month
    _addGstAutoReminders();
    setState(() {});
  }

  void _addGstAutoReminders() {
    final day = _selectedDay!.day;
    if (day == 11) {
      _reminders.add({
        'id': -1,
        'title': 'GSTR-1 Filing Due',
        'description': 'File GSTR-1 for last month on GST portal',
        'type': 'gst',
        'done': 0,
      });
    }
    if (day == 20) {
      _reminders.add({
        'id': -2,
        'title': 'GSTR-3B Payment Due',
        'description': 'Pay GST and file GSTR-3B',
        'type': 'gst',
        'done': 0,
      });
    }
  }

  Future<void> _addReminder() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    await DbHelper.insert('reminders', {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'remind_date': _selectedDay!.toIso8601String(),
      'type': 'custom',
      'done': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
    _titleCtrl.clear();
    _descCtrl.clear();
    _load();
  }

  Future<void> _toggleDone(int id) async {
    if (id < 0) return;
    await DbHelper.rawExecute(
        'UPDATE reminders SET done = CASE WHEN done = 1 THEN 0 ELSE 1 END WHERE id = ?',
        [id]);
    _load();
  }

  Future<void> _delete(int id) async {
    if (id < 0) return;
    await DbHelper.delete('reminders', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(
                                    _focusedDay.year, _focusedDay.month - 1, 1);
                              });
                            }),
                        Expanded(
                          child: Text(
                            '${_monthName(_focusedDay.month)} ${_focusedDay.year}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(
                                    _focusedDay.year, _focusedDay.month + 1, 1);
                              });
                            }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _calendarGrid(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Reminders for selected day
          Expanded(
            flex: 3,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders for ${_selectedDay!.day} ${_monthName(_selectedDay!.month)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reminder title',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _addReminder,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: _reminders.isEmpty
                          ? const Center(child: Text('No reminders for this day'))
                          : ListView.separated(
                              itemCount: _reminders.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, i) {
                                final r = _reminders[i];
                                final done = (r['done'] ?? 0) == 1;
                                final isGst = r['type'] == 'gst';
                                return ListTile(
                                  leading: Icon(
                                    isGst ? Icons.receipt : Icons.alarm,
                                    color: isGst ? Colors.brown : Colors.teal,
                                  ),
                                  title: Text(r['title'],
                                      style: TextStyle(
                                          decoration: done
                                              ? TextDecoration.lineThrough
                                              : null)),
                                  subtitle: r['description'] != null &&
                                          (r['description'] as String).isNotEmpty
                                      ? Text(r['description'])
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: done,
                                        onChanged: (v) =>
                                            _toggleDone(r['id'] as int),
                                      ),
                                      if (r['id'] is int && (r['id'] as int) > 0)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red, size: 20),
                                          onPressed: () =>
                                              _delete(r['id'] as int),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarGrid() {
    final first = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final startWeekday = first.weekday % 7;
    final cells = <Widget>[];
    for (final d in ['S', 'M', 'T', 'W', 'T', 'F', 'S']) {
      cells.add(Center(
          child: Text(d,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey))));
    }
    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, d);
      final isSel = _selectedDay != null &&
          _selectedDay!.year == date.year &&
          _selectedDay!.month == date.month &&
          _selectedDay!.day == date.day;
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;
      final hasReminder = d == 11 || d == 20;
      cells.add(GestureDetector(
        onTap: () {
          setState(() {
            _selectedDay = date;
          });
          _load();
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSel ? Colors.teal : null,
            shape: BoxShape.circle,
            border: isToday && !isSel
                ? Border.all(color: Colors.teal, width: 2)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('$d',
                  style: TextStyle(
                    color: isSel ? Colors.white : null,
                    fontWeight: isToday || isSel ? FontWeight.bold : null,
                  )),
              if (hasReminder && !isSel)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(Icons.circle, size: 6, color: Colors.red),
                ),
            ],
          ),
        ),
      ));
    }
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      children: cells,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  String _monthName(int m) => [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m - 1];
}
