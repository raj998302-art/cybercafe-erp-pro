import 'package:flutter/material.dart';

/// Help & tutorials screen (Phase 14).
/// Shows quick how-to guides for the older shop owner.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _guides = [
    _Guide(
      icon: Icons.receipt_long,
      color: Colors.teal,
      title: 'Create a Bill (Invoice)',
      steps: [
        'Tap "New Bill" from the dashboard or billing screen.',
        'Select a customer (or leave it blank for walk-in).',
        'Tap "Add Item" and pick from your saved price list.',
        'Change quantity if needed, then tap Update.',
        'Choose payment mode (Cash, UPI, Card, etc.).',
        'Tap "Save Bill" — done! Bill number is auto-generated.',
        'Use "View Details" to print or share the bill.',
      ],
    ),
    _Guide(
      icon: Icons.price_change,
      color: Colors.deepOrange,
      title: 'Set / Change Item Prices',
      steps: [
        'Go to "Items" from the side menu.',
        'Find the item and tap the three-dot menu.',
        'Choose "Edit".',
        'Change the "Price (₹)" field.',
        'Tap "Save" — all future bills use the new price.',
        'Old bills keep their original prices (historical).',
      ],
    ),
    _Guide(
      icon: Icons.person_add,
      color: Colors.indigo,
      title: 'Add a Customer',
      steps: [
        'Go to "Customers" from the side menu.',
        'Tap "New".',
        'Enter name, phone, and GSTIN (if they have one).',
        'Tap "Save".',
        'Now you can select this customer when making a bill.',
      ],
    ),
    _Guide(
      icon: Icons.backup,
      color: Colors.blue,
      title: 'Backup Your Data',
      steps: [
        'Go to "Settings".',
        'Under "Backup & Data", tap "Backup to File".',
        'A JSON file is saved to your Documents/CyberCafeERP/Backups folder.',
        'Copy this file to a pen drive or Google Drive for safety.',
        'To restore, use "Restore from File" and pick the JSON.',
      ],
    ),
    _Guide(
      icon: Icons.receipt,
      color: Colors.brown,
      title: 'View GST Returns',
      steps: [
        'Go to "GST" from the side menu.',
        'Pick the month (YYYY-MM format, e.g. 2024-03).',
        'See all bills, taxable value, and GST collected.',
        'Use this data to file GSTR-1 and GSTR-3B on the GST portal.',
      ],
    ),
    _Guide(
      icon: Icons.calculate,
      color: Colors.purple,
      title: 'Use the Calculator',
      steps: [
        'Open "Calculator" from the side menu.',
        'Use big buttons to add, subtract, multiply, divide.',
        'Tap "=" to see the result.',
        'Tap "C" to clear everything.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Help & Tutorials',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Step-by-step guides for common tasks. Tap a topic to expand.'),
        const SizedBox(height: 24),
        ..._guides.map((g) => _guideCard(context, g)),
      ],
    );
  }

  Widget _guideCard(BuildContext context, _Guide g) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: g.color.withOpacity(0.15),
          child: Icon(g.icon, color: g.color),
        ),
        title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: g.steps
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: g.color,
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(e.value,
                                    style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Guide {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> steps;
  const _Guide({
    required this.icon,
    required this.color,
    required this.title,
    required this.steps,
  });
}
