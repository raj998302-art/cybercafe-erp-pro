class AppConfig {
  static const String appName = 'CyberCafe ERP Pro';
  static const String appVersion = '1.0.0';
  static const String companyName = 'CyberCafe ERP';

  // Backend API base URL. The Windows app talks to a local Node.js backend
  // which connects to MongoDB Atlas. Override via env for production.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  // MongoDB direct connection (used by sync service for cloud backup)
  static const String mongoDbUri = String.fromEnvironment(
    'MONGODB_URI',
    defaultValue:
        'mongodb+srv://raj998302_db_user:RAJ998302@cottova.xjypjl0.mongodb.net/tc',
  );

  // GST configuration
  static const List<double> gstRates = [0, 0.25, 3, 5, 12, 18, 28];

  // Payment modes
  static const List<String> paymentModes = [
    'Cash',
    'UPI',
    'Card',
    'Net Banking',
    'Cheque',
    'Wallet',
    'Credit',
  ];

  // Voucher types (Tally-compatible)
  static const List<String> voucherTypes = [
    'Receipt',
    'Payment',
    'Journal',
    'Sales',
    'Purchase',
    'Credit Note',
    'Debit Note',
    'Contra',
  ];

  // Item categories for cyber cafe
  static const List<String> itemCategories = [
    'Print',
    'Xerox',
    'Cyber',
    'Govt Service',
    'Stationery',
    'Custom',
  ];

  static const List<String> units = [
    'Per Page',
    'Per Hour',
    'Per Set',
    'Per Form',
    'Per Piece',
    'Per Card',
    'Per Book',
    'Per Txn',
    'Flat',
    'Custom',
  ];
}
