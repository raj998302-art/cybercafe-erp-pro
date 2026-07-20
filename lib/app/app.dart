import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/config/app_config.dart';
import '../shared/theme/app_theme.dart';
import '../shared/providers/app_providers.dart';
import 'router.dart';

class CyberCafeErpApp extends StatelessWidget {
  const CyberCafeErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.all,
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.config,
        builder: (context, child) {
          return _KeyboardShortcuts(child: child ?? const SizedBox());
        },
      ),
    );
  }
}

/// Global keyboard shortcuts (Phase 10 — 13.2).
class _KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  const _KeyboardShortcuts({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): const _NewBillIntent(),
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): const _DailySummaryIntent(),
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): const _PrintIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): const _SettingsIntent(),
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): const _BillingIntent(),
        const SingleActivator(LogicalKeyboardKey.keyC, control: true): const _CustomerIntent(),
        const SingleActivator(LogicalKeyboardKey.f1): const _HelpIntent(),
        const SingleActivator(LogicalKeyboardKey.f2): const _CalculatorIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _NewBillIntent: CallbackAction<_NewBillIntent>(
            onInvoke: (_) => context.go('/billing/new'),
          ),
          _DailySummaryIntent: CallbackAction<_DailySummaryIntent>(
            onInvoke: (_) => context.go('/daily-summary'),
          ),
          _PrintIntent: CallbackAction<_PrintIntent>(
            onInvoke: (_) => context.go('/printing'),
          ),
          _SettingsIntent: CallbackAction<_SettingsIntent>(
            onInvoke: (_) => context.go('/settings'),
          ),
          _BillingIntent: CallbackAction<_BillingIntent>(
            onInvoke: (_) => context.go('/billing'),
          ),
          _CustomerIntent: CallbackAction<_CustomerIntent>(
            onInvoke: (_) => context.go('/customers'),
          ),
          _HelpIntent: CallbackAction<_HelpIntent>(
            onInvoke: (_) => context.go('/help'),
          ),
          _CalculatorIntent: CallbackAction<_CalculatorIntent>(
            onInvoke: (_) => context.go('/calculator'),
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

class _NewBillIntent extends Intent { const _NewBillIntent(); }
class _DailySummaryIntent extends Intent { const _DailySummaryIntent(); }
class _PrintIntent extends Intent { const _PrintIntent(); }
class _SettingsIntent extends Intent { const _SettingsIntent(); }
class _BillingIntent extends Intent { const _BillingIntent(); }
class _CustomerIntent extends Intent { const _CustomerIntent(); }
class _HelpIntent extends Intent { const _HelpIntent(); }
class _CalculatorIntent extends Intent { const _CalculatorIntent(); }
