import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/billing/billing_list_screen.dart';
import '../features/billing/billing_create_screen.dart';
import '../features/customers/customer_list_screen.dart';
import '../features/suppliers/supplier_screen.dart';
import '../features/inventory/item_list_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/reports/report_screen.dart';
import '../features/gst/gst_screen.dart';
import '../features/accounting/accounting_screen.dart';
import '../features/invoice_designer/invoice_designer_screen.dart';
import '../features/payroll/payroll_screen.dart';
import '../features/expenses/expense_screen.dart';
import '../features/calculator/calculator_screen.dart';
import '../features/notes/notes_screen.dart';
import '../features/help/help_screen.dart';
import '../shared/widgets/shell_scaffold.dart';

class AppRouter {
  static final config = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
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
            path: '/suppliers',
            name: 'suppliers',
            builder: (context, state) => const SupplierScreen(),
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
            path: '/expenses',
            name: 'expenses',
            builder: (context, state) => const ExpenseScreen(),
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
            path: '/payroll',
            name: 'payroll',
            builder: (context, state) => const PayrollScreen(),
          ),
          GoRoute(
            path: '/designer',
            name: 'designer',
            builder: (context, state) => const InvoiceDesignerScreen(),
          ),
          GoRoute(
            path: '/calculator',
            name: 'calculator',
            builder: (context, state) => const CalculatorScreen(),
          ),
          GoRoute(
            path: '/notes',
            name: 'notes',
            builder: (context, state) => const NotesScreen(),
          ),
          GoRoute(
            path: '/help',
            name: 'help',
            builder: (context, state) => const HelpScreen(),
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
