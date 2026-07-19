import 'package:flutter/material.dart';
import '../../core/backup/backup_service.dart';
import '../../core/services/api_service.dart';
import '../../core/config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _backendOnline = false;
  bool _checking = false;
  String _backupPath = '';

  @override
  void initState() {
    super.initState();
    _checkBackend();
    _loadBackupPath();
  }

  Future<void> _checkBackend() async {
    setState(() => _checking = true);
    final ok = await ApiService().ping();
    setState(() {
      _backendOnline = ok;
      _checking = false;
    });
  }

  Future<void> _loadBackupPath() async {
    final p = await BackupService.defaultBackupDir();
    setState(() => _backupPath = p);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _section('Company Profile', Icons.business, [
          const ListTile(
            leading: Icon(Icons.store, color: Colors.teal),
            title: Text('Shop Details'),
            subtitle: Text('Name, GSTIN, address, bank details, logo'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.receipt, color: Colors.amber),
            title: Text('Invoice Settings'),
            subtitle: Text('Prefix, counter, terms & conditions, signature'),
            trailing: Icon(Icons.chevron_right),
          ),
        ]),
        const SizedBox(height: 16),
        _section('Backup & Data', Icons.backup, [
          ListTile(
            leading: const Icon(Icons.cloud_download, color: Colors.blue),
            title: const Text('Backup to File'),
            subtitle: Text('Save all data as JSON to:\n$_backupPath'),
            isThreeLine: true,
            trailing: const Icon(Icons.download),
            onTap: () async {
              final path = await BackupService.exportToFile();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup saved to: $path')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.green),
            title: const Text('Restore from File'),
            subtitle: const Text('Import data from a previous backup'),
            trailing: const Icon(Icons.upload),
            onTap: () async {
              // file_picker integration would go here
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pick a backup JSON file')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync, color: Colors.purple),
            title: const Text('Sync with MongoDB Cloud'),
            subtitle: Text(
                'Backend: ${_checking ? "checking..." : _backendOnline ? "Online ✓" : "Offline"}'),
            trailing: const Icon(Icons.refresh),
            onTap: _checkBackend,
          ),
        ]),
        const SizedBox(height: 16),
        _section('About', Icons.info, [
          const ListTile(
            leading: Icon(Icons.apps, color: Colors.indigo),
            title: Text('CyberCafe ERP Pro'),
            subtitle: Text('Version 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.grey),
            title: const Text('Backend API URL'),
            subtitle: Text(AppConfig.apiBaseUrl),
          ),
        ]),
      ],
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
