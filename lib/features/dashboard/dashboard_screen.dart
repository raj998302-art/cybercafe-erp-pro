import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/services/gst_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DashboardProvider>();
    return RefreshIndicator(
      onRefresh: () => d.load(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _greeting(context),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _statCard(context, 'Today\'s Bills', '${d.todayBills}',
                  Icons.receipt_long, Colors.teal),
              _statCard(context, 'Today\'s Sales',
                  GstService.formatMoney(d.todayTotal), Icons.currency_rupee,
                  Colors.amber),
              _statCard(context, 'Customers', '${d.totalCustomers}',
                  Icons.people, Colors.indigo),
              _statCard(context, 'Items / Services', '${d.totalItems}',
                  Icons.inventory_2, Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 32),
          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _actionChip(context, 'New Bill', Icons.add_circle, '/billing/new',
                  Colors.teal),
              _actionChip(context, 'Add Customer', Icons.person_add,
                  '/customers', Colors.indigo),
              _actionChip(context, 'Set Prices', Icons.price_change,
                  '/inventory', Colors.deepOrange),
              _actionChip(context, 'Reports', Icons.assessment, '/reports',
                  Colors.purple),
              _actionChip(context, 'GST Returns', Icons.receipt, '/gst',
                  Colors.brown),
              _actionChip(context, 'Settings', Icons.settings, '/settings',
                  Colors.blueGrey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.teal,
              child: Icon(Icons.store, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greet, style: Theme.of(context).textTheme.titleMedium),
                  Text('CyberCafe ERP Pro',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Text('Welcome back! Here is your shop summary.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const Spacer(),
            Text(value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(BuildContext context, String label, IconData icon,
      String route, Color color) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, color: color),
      onPressed: () => context.go(route),
    );
  }
}
