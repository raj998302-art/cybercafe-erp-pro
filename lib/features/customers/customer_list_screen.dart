import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/models/customer.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});
  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CustomerProvider>();
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
                    labelText: 'Search customers',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => p.load(q: v),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _showForm(context),
                icon: const Icon(Icons.person_add),
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
                        child: Text('No customers yet',
                            style: TextStyle(color: Colors.grey.shade600)),
                      )
                    : ListView.separated(
                        itemCount: p.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final c = p.items[i];
                          return ListTile(
                            onTap: () => context.go('/customer/${c.id}'),
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade50,
                              child: Text(c.name.isNotEmpty
                                  ? c.name[0].toUpperCase()
                                  : '?'),
                            ),
                            title: Text(c.name),
                            subtitle: Text(
                                '${c.phone.isEmpty ? "No phone" : c.phone}${c.gstin.isNotEmpty ? " • GSTIN: ${c.gstin}" : ""}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') {
                                  _showForm(context, customer: c);
                                } else if (v == 'delete') {
                                  p.delete(c.id!);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('Delete')),
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

  void _showForm(BuildContext context, {Customer? customer}) {
    final name = TextEditingController(text: customer?.name ?? '');
    final phone = TextEditingController(text: customer?.phone ?? '');
    final email = TextEditingController(text: customer?.email ?? '');
    final gstin = TextEditingController(text: customer?.gstin ?? '');
    final address = TextEditingController(text: customer?.address ?? '');
    final state = TextEditingController(text: customer?.state ?? '');
    final opening = TextEditingController(
        text: (customer?.openingBalance ?? 0).toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(customer == null ? 'New Customer' : 'Edit Customer'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _f('Name *', name),
                _f('Phone', phone),
                _f('Email', email),
                _f('GSTIN', gstin, upper: true),
                _f('Address', address, max: 2),
                _f('State (for GST intra/inter-state)', state),
                _f('Opening Balance', opening, num: true),
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
              context.read<CustomerProvider>().upsert(Customer(
                    id: customer?.id,
                    name: name.text.trim(),
                    phone: phone.text.trim(),
                    email: email.text.trim(),
                    gstin: gstin.text.trim().toUpperCase(),
                    address: address.text.trim(),
                    state: state.text.trim(),
                    openingBalance:
                        double.tryParse(opening.text) ?? 0,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController c,
      {bool num = false, bool upper = false, int max = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        maxLines: max,
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
