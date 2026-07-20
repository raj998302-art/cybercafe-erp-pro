import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Phase 10 — Built-in File Manager Screen (13.4).
/// Browse the Windows file system, navigate folders, view backup files.
class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});
  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  Directory? _currentDir;
  List<FileSystemEntity> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _goHome();
  }

  Future<void> _goHome() async {
    final docs = await getApplicationDocumentsDirectory();
    final base = Directory(p.join(docs.path, 'CyberCafeERP'));
    if (!base.existsSync()) base.createSync(recursive: true);
    _navigate(base);
  }

  Future<void> _navigate(Directory dir) async {
    setState(() => _loading = true);
    _currentDir = dir;
    try {
      _entries = dir.listSync().toList()..sort((a, b) {
        if (a is Directory && b is! Directory) return -1;
        if (a is! Directory && b is Directory) return 1;
        return p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase());
      });
    } catch (e) {
      _entries = [];
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentDir != null ? p.basename(_currentDir!.path) : 'File Manager'),
        actions: [
          IconButton(icon: const Icon(Icons.home), onPressed: _goHome, tooltip: 'Home'),
          IconButton(icon: const Icon(Icons.create_new_folder), onPressed: _newFolder, tooltip: 'New Folder'),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Text(_currentDir?.path ?? '',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis),
          ),
          if (_currentDir?.parent != null)
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.amber),
              title: const Text('.. (Parent)'),
              onTap: () => _navigate(_currentDir!.parent),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? const Center(child: Text('Folder is empty'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, i) {
                          final e = _entries[i];
                          final name = p.basename(e.path);
                          final isDir = e is Directory;
                          return ListTile(
                            leading: Icon(
                              isDir ? Icons.folder : _fileIcon(name),
                              color: isDir ? Colors.amber : Colors.blue,
                              size: 32,
                            ),
                            title: Text(name),
                            subtitle: isDir ? null : Text(_fileSize(e as File)),
                            onTap: isDir ? () => _navigate(e as Directory) : () => _openFile(e as File),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  IconData _fileIcon(String name) {
    final ext = p.extension(name).toLowerCase();
    switch (ext) {
      case '.pdf': return Icons.picture_as_pdf;
      case '.json': return Icons.data_object;
      case '.jpg':
      case '.jpeg':
      case '.png': return Icons.image;
      case '.xlsx':
      case '.csv': return Icons.table_chart;
      case '.doc':
      case '.docx': return Icons.description;
      case '.txt': return Icons.text_snippet;
      default: return Icons.insert_drive_file;
    }
  }

  String _fileSize(File f) {
    try {
      final bytes = f.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  void _openFile(File f) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File: ${f.path}')));
  }

  void _newFolder() async {
    final name = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('New Folder'),
      content: TextField(controller: name, decoration: const InputDecoration(labelText: 'Folder name', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final dir = Directory(p.join(_currentDir!.path, name.text));
          dir.createSync(recursive: true);
          Navigator.pop(ctx);
          _navigate(_currentDir!);
        }, child: const Text('Create')),
      ],
    ));
  }
}
