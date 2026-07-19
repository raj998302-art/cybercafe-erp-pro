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
  NavItem('/inventory', Icons.inventory_2_outlined, 'Items'),
  NavItem('/accounting', Icons.account_balance_outlined, 'Accounts'),
  NavItem('/gst', Icons.receipt_outlined, 'GST'),
  NavItem('/reports', Icons.assessment_outlined, 'Reports'),
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
            NavigationRail(
              selectedIndex: _selectedIndex(location),
              onDestinationSelected: (i) => context.go(_navItems[i].path),
              extended: MediaQuery.of(context).size.width >= 1400,
              minExtendedWidth: 220,
              backgroundColor: theme.colorScheme.surface,
              indicatorColor: theme.colorScheme.primary,
              selectedIconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
              selectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              leading: const _AppBrand(),
              destinations: _navItems
                  .map((n) => NavigationRailDestination(
                        icon: Icon(n.icon),
                        label: Text(n.label),
                      ))
                  .toList(),
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
                  .map((n) => NavigationDestination(
                        icon: Icon(n.icon),
                        label: n.label,
                      ))
                  .toList(),
            ),
    );
  }

  int _selectedIndex(String location) {
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path == '/' ? '/' : _navItems[i].path)) {
        if (_navItems[i].path == '/' && location != '/') continue;
        return i;
      }
    }
    return 0;
  }

  String _currentTitle(String location) {
    for (final n in _navItems) {
      if (location.startsWith(n.path == '/' ? '/' : n.path)) {
        if (n.path == '/' && location != '/') continue;
        return n.label;
      }
    }
    return AppConfig.appName;
  }
}

class _AppBrand extends StatelessWidget {
  const _AppBrand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.store, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            AppConfig.appName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
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
