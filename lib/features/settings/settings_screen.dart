import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/backup/backup_service.dart';
import '../../core/database/db_helper.dart';
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
          ListTile(
            leading: const Icon(Icons.store, color: Colors.teal),
            title: const Text('Shop Details'),
            subtitle: const Text('Name, GSTIN, address, bank details, logo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCompanyForm(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt, color: Colors.amber),
            title: const Text('Invoice Settings'),
            subtitle: const Text('Prefix, counter, terms & conditions, signature'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showInvoiceSettings(context),
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
              try {
                final path = await BackupService.exportToFile();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup saved to: $path')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup failed: $e')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.green),
            title: const Text('Restore from File'),
            subtitle: const Text('Import data from a previous backup'),
            trailing: const Icon(Icons.upload),
            onTap: () async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (result == null || result.files.single.path == null) return;
                final count = await BackupService.importFromFile(result.files.single.path!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored $count records successfully')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restore failed: $e')));
                }
              }
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

  void _showCompanyForm(BuildContext context) async {
    final existing = await DbHelper.first('company');
    final name = TextEditingController(text: existing?['name'] as String? ?? '');
    final gstin = TextEditingController(text: existing?['gstin'] as String? ?? '');
    final phone = TextEditingController(text: existing?['phone'] as String? ?? '');
    final email = TextEditingController(text: existing?['email'] as String? ?? '');
    final addr1 = TextEditingController(text: existing?['address_line1'] as String? ?? '');
    final city = TextEditingController(text: existing?['city'] as String? ?? '');
    final state = TextEditingController(text: existing?['state'] as String? ?? 'Maharashtra');
    final pincode = TextEditingController(text: existing?['pincode'] as String? ?? '');
    final bankName = TextEditingController(text: existing?['bank_name'] as String? ?? '');
    final acctNo = TextEditingController(text: existing?['account_number'] as String? ?? '');
    final ifsc = TextEditingController(text: existing?['ifsc'] as String? ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Shop / Company Details'),
        content: SizedBox(width: 480, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _f('Shop Name *', name), _f('GSTIN', gstin, upper: true),
          _f('Phone', phone), _f('Email', email),
          _f('Address Line 1', addr1), _f('City', city),
          _f('State', state), _f('Pincode', pincode),
          const Divider(), _f('Bank Name', bankName),
          _f('Account Number', acctNo), _f('IFSC', ifsc, upper: true),
        ]))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            final data = {
              'name': name.text.trim(), 'gstin': gstin.text.trim().toUpperCase(),
              'phone': phone.text, 'email': email.text,
              'address_line1': addr1.text, 'city': city.text,
              'state': state.text, 'pincode': pincode.text,
              'bank_name': bankName.text, 'account_number': acctNo.text,
              'ifsc': ifsc.text.trim().toUpperCase(),
              'updated_at': DateTime.now().toIso8601String(),
            };
            if (existing == null) {
              await DbHelper.insert('company', data);
            } else {
              await DbHelper.update('company', data, where: 'id = ?', whereArgs: [existing['id']]);
            }
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company details saved')));
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showInvoiceSettings(BuildContext context) async {
    final prefixRow = await DbHelper.first('settings', where: 'key = ?', whereArgs: ['invoice_prefix']);
    final counterRow = await DbHelper.first('settings', where: 'key = ?', whereArgs: ['invoice_counter']);
    final termsRow = await DbHelper.first('settings', where: 'key = ?', whereArgs: ['terms_conditions']);
    final prefix = TextEditingController(text: prefixRow?['value'] as String? ?? 'INV');
    final counter = TextEditingController(text: counterRow?['value'] as String? ?? '0');
    final terms = TextEditingController(text: termsRow?['value'] as String? ?? 'Goods once sold will not be taken back.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invoice Settings'),
        content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _f('Invoice Prefix', prefix, upper: true),
          _f('Current Counter', counter, num: true),
          const SizedBox(height: 8),
          TextField(controller: terms, maxLines: 3, decoration: const InputDecoration(labelText: 'Terms & Conditions', border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            await _upsertSetting('invoice_prefix', prefix.text.trim().toUpperCase());
            await _upsertSetting('invoice_counter', counter.text.trim());
            await _upsertSetting('terms_conditions', terms.text.trim());
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice settings saved')));
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _upsertSetting(String key, String value) async {
    final existing = await DbHelper.first('settings', where: 'key = ?', whereArgs: [key]);
    if (existing == null) {
      await DbHelper.insert('settings', {'key': key, 'value': value});
    } else {
      await DbHelper.update('settings', {'value': value}, where: 'key = ?', whereArgs: [key]);
    }
  }

  Widget _f(String label, TextEditingController c, {bool num = false, bool upper = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: TextField(
      controller: c,
      keyboardType: num ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      textCapitalization: upper ? TextCapitalization.characters : TextCapitalization.words,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    ));
  }
}
