import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

/// Quick notes system (Phase 14 — advanced tools).
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ensureTable();
    _load();
  }

  Future<void> _ensureTable() async {
    await DbHelper.rawExecute('''
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        color TEXT DEFAULT '#FFF9C4',
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _notes = await DbHelper.query('notes', orderBy: 'updated_at DESC');
    setState(() => _loading = false);
  }

  Future<void> _upsert(Map<String, dynamic> n) async {
    final now = DateTime.now().toIso8601String();
    final map = {...n, 'updated_at': now};
    if (n['id'] == null) {
      map['created_at'] = now;
      await DbHelper.insert('notes', map);
    } else {
      await DbHelper.update('notes', map, where: 'id = ?', whereArgs: [n['id']]);
    }
    _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.delete('notes', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text('My Notes',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showForm(context),
                icon: const Icon(Icons.note_add),
                label: const Text('New Note'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? Center(
                        child: Text('No notes yet',
                            style: TextStyle(color: Colors.grey.shade600)),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          childAspectRatio: 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _notes.length,
                        itemBuilder: (context, i) {
                          final n = _notes[i];
                          return Card(
                            color: _parseColor(n['color'] as String? ?? '#FFF9C4'),
                            child: InkWell(
                              onTap: () => _showForm(context, note: n),
                              onLongPress: () => _delete(n['id'] as int),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n['title'] ?? 'Untitled',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Text(n['body'] ?? '',
                                          style: const TextStyle(fontSize: 13),
                                          maxLines: 6,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    Text(
                                      (n['updated_at'] as String?)
                                              ?.substring(0, 16) ??
                                          '',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, {Map<String, dynamic>? note}) {
    final title = TextEditingController(text: note?['title'] ?? '');
    final body = TextEditingController(text: note?['body'] ?? '');
    String color = note?['color'] as String? ?? '#FFF9C4';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(note == null ? 'New Note' : 'Edit Note'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: body,
                  maxLines: 6,
                  decoration: const InputDecoration(
                      labelText: 'Note', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['#FFF9C4', '#FFCDD2', '#C8E6C9', '#BBDEFB', '#FFFFFF']
                      .map((c) => GestureDetector(
                            onTap: () => setS(() => color = c),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _parseColor(c),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: color == c
                                        ? Colors.teal
                                        : Colors.grey.shade300,
                                    width: color == c ? 3 : 1),
                              ),
                            ),
                          ))
                      .toList(),
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
                _upsert({
                  'id': note?['id'],
                  'title': title.text.trim(),
                  'body': body.text.trim(),
                  'color': color,
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return Colors.yellow.shade100;
  }
}
