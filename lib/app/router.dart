import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/billing/billing_list_screen.dart';
import '../features/billing/billing_create_screen.dart';
import '../features/customers/customer_list_screen.dart';
import '../features/inventory/item_list_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/reports/report_screen.dart';
import '../features/gst/gst_screen.dart';
import '../features/accounting/accounting_screen.dart';
import '../shared/widgets/shell_scaffold.dart';

class AppRouter {
  static final config = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/billing',
            name: 'billing',
            builder: (context, state) => const BillingListScreen(),
          ),
          GoRoute(
            path: '/billing/new',
            name: 'billing-new',
            builder: (context, state) => const BillingCreateScreen(),
          ),
          GoRoute(
            path: '/customers',
            name: 'customers',
            builder: (context, state) => const CustomerListScreen(),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const ItemListScreen(),
          ),
          GoRoute(
            path: '/accounting',
            name: 'accounting',
            builder: (context, state) => const AccountingScreen(),
          ),
          GoRoute(
            path: '/gst',
            name: 'gst',
            builder: (context, state) => const GstScreen(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
