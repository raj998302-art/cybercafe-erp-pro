import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/billing/billing_list_screen.dart';
import '../features/billing/billing_create_screen.dart';
import '../features/customers/customer_list_screen.dart';
import '../features/customer_detail/customer_detail_screen.dart';
import '../features/suppliers/supplier_screen.dart';
import '../features/inventory/item_list_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/reports/report_screen.dart';
import '../features/reports/daily_summary_screen.dart';
import '../features/advanced_reports/advanced_reports_screen.dart';
import '../features/gst/gst_screen.dart';
import '../features/einvoice/einvoice_screen.dart';
import '../features/accounting/accounting_screen.dart';
import '../features/accounting/accounting_extras_screen.dart';
import '../features/purchase/purchase_screen.dart';
import '../features/invoice_designer/invoice_designer_screen.dart';
import '../features/payroll/payroll_screen.dart';
import '../features/hr/hr_screen.dart';
import '../features/expenses/expense_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/cheques/cheque_screen.dart';
import '../features/upi_qr/upi_qr_screen.dart';
import '../features/recycle_bin/recycle_bin_screen.dart';
import '../features/multi_company/multi_company_screen.dart';
import '../features/vehicles/vehicle_screen.dart';
import '../features/printing_system/printing_system_screen.dart';
import '../features/file_manager/file_manager_screen.dart';
import '../features/calculator/calculator_screen.dart';
import '../features/notes/notes_screen.dart';
import '../features/help/help_screen.dart';
import '../shared/widgets/shell_scaffold.dart';

class AppRouter {
  static final config = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (c, s) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(path: '/', name: 'dashboard', builder: (c, s) => const DashboardScreen()),
          GoRoute(path: '/billing', name: 'billing', builder: (c, s) => const BillingListScreen()),
          GoRoute(path: '/billing/new', name: 'billing-new', builder: (c, s) => const BillingCreateScreen()),
          GoRoute(path: '/customers', name: 'customers', builder: (c, s) => const CustomerListScreen()),
          GoRoute(
            path: '/customer/:id',
            builder: (c, s) {
              final id = int.tryParse(s.pathParameters['id'] ?? '0') ?? 0;
              return CustomerDetailScreen(customerId: id);
            },
          ),
          GoRoute(path: '/suppliers', name: 'suppliers', builder: (c, s) => const SupplierScreen()),
          GoRoute(path: '/inventory', name: 'inventory', builder: (c, s) => const ItemListScreen()),
          GoRoute(path: '/purchase', name: 'purchase', builder: (c, s) => const PurchaseScreen()),
          GoRoute(path: '/accounting', name: 'accounting', builder: (c, s) => const AccountingScreen()),
          GoRoute(path: '/accounting-extras', name: 'accounting-extras', builder: (c, s) => const AccountingExtrasScreen()),
          GoRoute(path: '/expenses', name: 'expenses', builder: (c, s) => const ExpenseScreen()),
          GoRoute(path: '/payroll', name: 'payroll', builder: (c, s) => const PayrollScreen()),
          GoRoute(path: '/hr', name: 'hr', builder: (c, s) => const HrScreen()),
          GoRoute(path: '/gst', name: 'gst', builder: (c, s) => const GstScreen()),
          GoRoute(path: '/gst-compliance', name: 'gst-compliance', builder: (c, s) => const GstComplianceScreen()),
          GoRoute(path: '/einvoice', name: 'einvoice', builder: (c, s) => const EInvoiceScreen()),
          GoRoute(path: '/reports', name: 'reports', builder: (c, s) => const ReportScreen()),
          GoRoute(path: '/daily-summary', name: 'daily-summary', builder: (c, s) => const DailySummaryScreen()),
          GoRoute(path: '/advanced-reports', name: 'advanced-reports', builder: (c, s) => const AdvancedReportsScreen()),
          GoRoute(path: '/designer', name: 'designer', builder: (c, s) => const InvoiceDesignerScreen()),
          GoRoute(path: '/printing', name: 'printing', builder: (c, s) => const PrintingSystemScreen()),
          GoRoute(path: '/calendar', name: 'calendar', builder: (c, s) => const CalendarScreen()),
          GoRoute(path: '/cheques', name: 'cheques', builder: (c, s) => const ChequeScreen()),
          GoRoute(path: '/upi-qr', name: 'upi-qr', builder: (c, s) => const UpiQrScreen()),
          GoRoute(path: '/vehicles', name: 'vehicles', builder: (c, s) => const VehicleScreen()),
          GoRoute(path: '/file-manager', name: 'file-manager', builder: (c, s) => const FileManagerScreen()),
          GoRoute(path: '/recycle-bin', name: 'recycle-bin', builder: (c, s) => const RecycleBinScreen()),
          GoRoute(path: '/companies', name: 'companies', builder: (c, s) => const MultiCompanyScreen()),
          GoRoute(path: '/calculator', name: 'calculator', builder: (c, s) => const CalculatorScreen()),
          GoRoute(path: '/notes', name: 'notes', builder: (c, s) => const NotesScreen()),
          GoRoute(path: '/help', name: 'help', builder: (c, s) => const HelpScreen()),
          GoRoute(path: '/settings', name: 'settings', builder: (c, s) => const SettingsScreen()),
        ],
      ),
    ],
  );
}
