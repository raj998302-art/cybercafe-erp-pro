import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      ),
    );
  }
}
