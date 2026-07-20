import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/gst_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Phase 14 — Vehicle & Fuel Expense (17.7) + Document Attachment (17.9).
class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});
  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _fuel = [];
  List<Map<String, dynamic>> _docs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _ensureTables();
    _load();
  }

  Future<void> _ensureTables() async {
    for (final sql in [
      "CREATE TABLE IF NOT EXISTS vehicles (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, number TEXT, fuel_type TEXT, odometer INTEGER DEFAULT 0, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS fuel_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, vehicle_id INTEGER, date TEXT, liters REAL, amount REAL, odometer INTEGER, station TEXT, created_at TEXT)",
      "CREATE TABLE IF NOT EXISTS documents (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, entity_type TEXT, entity_id INTEGER, file_path TEXT, description TEXT, created_at TEXT)",
    ]) { try { await DbHelper.rawExecute(sql); } catch (_) {} }
  }

  Future<void> _load() async {
    _vehicles = await DbHelper.query('vehicles', orderBy: 'name');
    _fuel = await DbHelper.query('fuel_entries', orderBy: 'date DESC');
    _docs = await DbHelper.query('documents', orderBy: 'id DESC');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles, Fuel & Documents'),
        bottom: TabBar(controller: _tab, tabs: const [
          Tab(text: 'Vehicles'), Tab(text: 'Fuel Log'), Tab(text: 'Documents'),
        ]),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : TabBarView(controller: _tab, children: [
        _vehicleTab(), _fuelTab(), _docTab(),
      ]),
    );
  }

  Widget _vehicleTab() => Scaffold(
    floatingActionButton: FloatingActionButton(onPressed: _addVehicle, child: const Icon(Icons.add)),
    body: _vehicles.isEmpty ? const Center(child: Text('No vehicles yet')) : ListView.separated(
      itemCount: _vehicles.length, separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final v = _vehicles[i];
        return ListTile(leading: const Icon(Icons.directions_car, color: Colors.blue), title: Text('${v['name']} (${v['number']})'), subtitle: Text('Fuel: ${v['fuel_type']} • Odometer: ${v['odometer']} km'));
      },
    ),
  );

  Widget _fuelTab() => Scaffold(
    floatingActionButton: FloatingActionButton(onPressed: _addFuel, child: const Icon(Icons.local_gas_station)),
    body: Column(children: [
      Card(margin: const EdgeInsets.all(16), child: Padding(padding: const EdgeInsets.all(16), child: Text('Total Fuel Cost: ${GstService.formatMoney(_fuel.fold(0.0, (s, f) => s + ((f['amount'] as num?)?.toDouble() ?? 0)))}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
      Expanded(child: _fuel.isEmpty ? const Center(child: Text('No fuel entries')) : ListView.separated(
        itemCount: _fuel.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final f = _fuel[i];
          final v = _vehicles.where((e) => e['id'] == f['vehicle_id']).firstOrNull;
          return ListTile(leading: const Icon(Icons.local_gas_station, color: Colors.red), title: Text('${v?['name'] ?? "Vehicle #${f['vehicle_id']}"}'), subtitle: Text('${f['date']?.toString().substring(0, 10) ?? ""} • ${f['liters']} L • ${GstService.formatMoney((f['amount'] as num?)?.toDouble() ?? 0)} • ${f['station'] ?? ""}'));
        },
      )),
    ]),
  );

  Widget _docTab() => Scaffold(
    floatingActionButton: FloatingActionButton(onPressed: _addDoc, child: const Icon(Icons.attach_file)),
    body: _docs.isEmpty ? const Center(child: Text('No documents attached')) : ListView.separated(
      itemCount: _docs.length, separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final d = _docs[i];
        return ListTile(leading: const Icon(Icons.insert_drive_file, color: Colors.indigo), title: Text(d['title']), subtitle: Text('${d['entity_type'] ?? ""} • ${d['description'] ?? ""}'), trailing: IconButton(icon: const Icon(Icons.open_in_new), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File: ${d['file_path']}'))); }));
      },
    ),
  );

  void _addVehicle() {
    final name = TextEditingController();
    final number = TextEditingController();
    String fuel = 'Petrol';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('Add Vehicle'),
      content: SizedBox(width: 350, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Vehicle Name', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: number, decoration: const InputDecoration(labelText: 'Number Plate', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: fuel, decoration: const InputDecoration(labelText: 'Fuel Type', border: OutlineInputBorder()),
          items: const ['Petrol', 'Diesel', 'CNG', 'Electric'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setS(() => fuel = v ?? 'Petrol')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          await DbHelper.insert('vehicles', {'name': name.text, 'number': number.text, 'fuel_type': fuel, 'odometer': 0, 'created_at': DateTime.now().toIso8601String()});
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('Save')),
      ],
    )));
  }

  void _addFuel() {
    final liters = TextEditingController();
    final amount = TextEditingController();
    final odometer = TextEditingController();
    final station = TextEditingController();
    int? vid;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('Add Fuel Entry'),
      content: SizedBox(width: 350, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: vid, decoration: const InputDecoration(labelText: 'Vehicle', border: OutlineInputBorder()),
          items: _vehicles.map((v) => DropdownMenuItem(value: v['id'] as int, child: Text('${v['name']} (${v['number']})'))).toList(),
          onChanged: (v) => setS(() => vid = v)),
        const SizedBox(height: 8),
        TextField(controller: liters, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Liters', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: odometer, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer (km)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: station, decoration: const InputDecoration(labelText: 'Station', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          if (vid == null) return;
          await DbHelper.insert('fuel_entries', {'vehicle_id': vid, 'date': DateTime.now().toIso8601String(), 'liters': double.tryParse(liters.text) ?? 0, 'amount': double.tryParse(amount.text) ?? 0, 'odometer': int.tryParse(odometer.text) ?? 0, 'station': station.text, 'created_at': DateTime.now().toIso8601String()});
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('Save')),
      ],
    )));
  }

  void _addDoc() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path ?? '';
    final title = TextEditingController(text: result.files.single.name);
    final desc = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Attach Document'),
      content: SizedBox(width: 350, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('File: ${result.files.single.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          await DbHelper.insert('documents', {'title': title.text, 'entity_type': 'general', 'entity_id': 0, 'file_path': path, 'description': desc.text, 'created_at': DateTime.now().toIso8601String()});
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('Save')),
      ],
    ));
  }
}
