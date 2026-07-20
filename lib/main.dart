// CyberCafe ERP Pro - Main Entry Point
// A complete GST billing + accounting + invoice designer app for Indian cyber cafes.
library cybercafe_erp;

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/database/database_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local SQLite database (offline-first)
  await DatabaseInit.initialize();

  runApp(const CyberCafeErpApp());
}
