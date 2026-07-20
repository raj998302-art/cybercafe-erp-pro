import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';

class NavItem {
  final String path;
  final IconData icon;
  final String label;
  const NavItem(this.path, this.icon, this.label);
}

const List<NavItem> _navItems = [
  NavItem('/', Icons.dashboard_outlined, 'Dashboard'),
  NavItem('/billing', Icons.receipt_long_outlined, 'Billing'),
  NavItem('/customers', Icons.people_outline, 'Customers'),
  NavItem('/suppliers', Icons.local_shipping_outlined, 'Suppliers'),
  NavItem('/inventory', Icons.inventory_2_outlined, 'Items'),
  NavItem('/accounting', Icons.account_balance_outlined, 'Accounts'),
  NavItem('/expenses', Icons.money_off_outlined, 'Expenses'),
  NavItem('/payroll', Icons.badge_outlined, 'Payroll'),
  NavItem('/gst', Icons.receipt_outlined, 'GST Returns'),
  NavItem('/einvoice', Icons.qr_code_outlined, 'E-Invoice / EWB'),
  NavItem('/reports', Icons.assessment_outlined, 'Reports'),
  NavItem('/advanced-reports', Icons.analytics_outlined, 'Advanced Reports'),
  NavItem('/designer', Icons.design_services_outlined, 'Invoice Designer'),
  NavItem('/calendar', Icons.calendar_month_outlined, 'Calendar'),
  NavItem('/cheques', Icons.account_balance_wallet_outlined, 'Cheques'),
  NavItem('/upi-qr', Icons.qr_code, 'UPI QR'),
  NavItem('/recycle-bin', Icons.delete_outline, 'Recycle Bin'),
  NavItem('/companies', Icons.business_outlined, 'Multi-Company'),
  NavItem('/calculator', Icons.calculate_outlined, 'Calculator'),
  NavItem('/notes', Icons.sticky_note_2_outlined, 'Notes'),
  NavItem('/help', Icons.help_outline, 'Help'),
  NavItem('/settings', Icons.settings_outlined, 'Settings'),
];

class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: MediaQuery.of(context).size.width >= 1400 ? 240 : 72,
              child: Drawer(
                backgroundColor: theme.colorScheme.surface,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const _AppBrand(),
                    ..._navItems.map((n) {
                      final selected = _isSelected(location, n.path);
                      return ListTile(
                        leading: Icon(n.icon,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant),
                        title: MediaQuery.of(context).size.width >= 1400
                            ? Text(n.label,
                                style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : null))
                            : null,
                        selected: selected,
                        selectedTileColor: theme.colorScheme.primaryContainer,
                        onTap: () => context.go(n.path),
                      );
                    }).toList(),
                  ],
                ),
              ),
            )
          else
            Container(),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: _currentTitle(location)),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex(location),
              onDestinationSelected: (i) => context.go(_navItems[i].path),
              destinations: _navItems
                  .take(5)
                  .map((n) => NavigationDestination(
                        icon: Icon(n.icon),
                        label: n.label,
                      ))
                  .toList(),
            ),
    );
  }

  bool _isSelected(String location, String path) {
    if (path == '/') return location == '/';
    return location.startsWith(path);
  }

  int _selectedIndex(String location) {
    for (int i = 0; i < _navItems.length; i++) {
      if (_isSelected(location, _navItems[i].path)) return i;
    }
    return 0;
  }

  String _currentTitle(String location) {
    for (final n in _navItems) {
      if (_isSelected(location, n.path)) return n.label;
    }
    return AppConfig.appName;
  }
}

class _AppBrand extends StatelessWidget {
  const _AppBrand();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1400;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.store, color: Colors.white, size: 24),
          ),
          if (isWide) ...[
            const SizedBox(height: 8),
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.teal),
            tooltip: 'New Bill',
            onPressed: () => context.go('/billing/new'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
