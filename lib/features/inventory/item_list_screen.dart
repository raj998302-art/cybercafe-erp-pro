import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/models/item.dart';
import '../../core/config/app_config.dart';
import '../../core/services/gst_service.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});
  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ItemProvider>().seedDefaults();
      if (mounted) context.read<ItemProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ItemProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    labelText: 'Search items / services',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => p.load(q: v),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _showForm(context),
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: p.loading && p.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : p.items.isEmpty
                    ? Center(
                        child: Text('No items',
                            style: TextStyle(color: Colors.grey.shade600)),
                      )
                    : ListView.separated(
                        itemCount: p.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final it = p.items[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepOrange.shade50,
                              child: Text(it.shortName.isNotEmpty
                                  ? it.shortName.substring(0, 2).toUpperCase()
                                  : '?'),
                            ),
                            title: Text(it.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${it.category} • ${it.unit} • GST ${it.gstRate}%${it.hsnCode.isNotEmpty ? " • HSN ${it.hsnCode}" : ""}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(GstService.formatMoney(it.price),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal)),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      _showForm(context, item: it);
                                    } else if (v == 'delete') {
                                      p.delete(it.id!);
                                    }
                                  },
                                  itemBuilder: (_) => const [
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

  void _showForm(BuildContext context, {Item? item}) {
    final name = TextEditingController(text: item?.name ?? '');
    final short = TextEditingController(text: item?.shortName ?? '');
    final price = TextEditingController(
        text: (item?.price ?? 0).toStringAsFixed(2));
    String category = item?.category ?? 'Print';
    String unit = item?.unit ?? 'Per Page';
    double gstRate = item?.gstRate ?? 18;
    final hsn = TextEditingController(text: item?.hsnCode ?? '');
    bool isService = item?.isService ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(item == null ? 'New Item / Service' : 'Edit Item'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _f('Name *', name),
                  _f('Short Name', short, upper: true),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder()),
                          items: AppConfig.itemCategories
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setS(() => category = v ?? 'Custom'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: unit,
                          decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder()),
                          items: AppConfig.units
                              .map((u) => DropdownMenuItem(
                                  value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) =>
                              setS(() => unit = v ?? 'Flat'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _f('Price (₹)', price, num: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: gstRate,
                          decoration: const InputDecoration(
                              labelText: 'GST %',
                              border: OutlineInputBorder()),
                          items: AppConfig.gstRates
                              .map((g) => DropdownMenuItem(
                                  value: g, child: Text('${g}%')))
                              .toList(),
                          onChanged: (v) =>
                              setS(() => gstRate = v ?? 0),
                        ),
                      ),
                    ],
                  ),
                  _f('HSN / SAC Code', hsn, upper: true),
                  SwitchListTile(
                    title: const Text('Is a service (not physical stock)'),
                    value: isService,
                    onChanged: (v) => setS(() => isService = v),
                  ),
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
                context.read<ItemProvider>().upsert(Item(
                      id: item?.id,
                      name: name.text.trim(),
                      shortName: short.text.trim().toUpperCase(),
                      category: category,
                      unit: unit,
                      price: double.tryParse(price.text) ?? 0,
                      gstRate: gstRate,
                      hsnCode: hsn.text.trim().toUpperCase(),
                      isService: isService,
                      active: item?.active ?? true,
                      sortOrder: item?.sortOrder ?? 0,
                    ));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(String label, TextEditingController c,
      {bool num = false, bool upper = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textCapitalization:
            upper ? TextCapitalization.characters : TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
