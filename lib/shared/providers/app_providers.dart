import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/item.dart';
import '../models/bill.dart';

class AppProviders {
  static final all = [
    ChangeNotifierProvider(create: (_) => DashboardProvider()),
    ChangeNotifierProvider(create: (_) => CustomerProvider()),
    ChangeNotifierProvider(create: (_) => ItemProvider()),
    ChangeNotifierProvider(create: (_) => BillProvider()),
  ];
}

class DashboardProvider extends ChangeNotifier {
  int _todayBills = 0;
  double _todayTotal = 0;
  int _totalCustomers = 0;
  int _totalItems = 0;
  bool _loading = false;

  int get todayBills => _todayBills;
  double get todayTotal => _todayTotal;
  int get totalCustomers => _totalCustomers;
  int get totalItems => _totalItems;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _todayBills = await BillRepository.todayCount();
    _todayTotal = await BillRepository.todayTotal();
    final custs = await CustomerRepository.all();
    final items = await ItemRepository.all();
    _totalCustomers = custs.length;
    _totalItems = items.length;
    _loading = false;
    notifyListeners();
  }
}

class CustomerProvider extends ChangeNotifier {
  List<Customer> _items = [];
  bool _loading = false;
  String _query = '';

  List<Customer> get items => _items;
  bool get loading => _loading;

  Future<void> load({String q = ''}) async {
    _loading = true;
    _query = q;
    notifyListeners();
    _items = await CustomerRepository.all(q: _query);
    _loading = false;
    notifyListeners();
  }

  Future<void> upsert(Customer c) async {
    await CustomerRepository.upsert(c);
    await load(q: _query);
  }

  Future<void> delete(int id) async {
    await CustomerRepository.delete(id);
    await load(q: _query);
  }
}

class ItemProvider extends ChangeNotifier {
  List<Item> _items = [];
  bool _loading = false;
  String _query = '';

  List<Item> get items => _items;
  bool get loading => _loading;

  Future<void> load({String q = ''}) async {
    _loading = true;
    _query = q;
    notifyListeners();
    _items = await ItemRepository.all(q: _query);
    _loading = false;
    notifyListeners();
  }

  Future<void> upsert(Item i) async {
    await ItemRepository.upsert(i);
    await load(q: _query);
  }

  Future<void> delete(int id) async {
    await ItemRepository.delete(id);
    await load(q: _query);
  }

  Future<void> seedDefaults() async {
    await ItemRepository.seedDefaults();
    await load();
  }
}

class BillProvider extends ChangeNotifier {
  List<Bill> _items = [];
  bool _loading = false;
  String _query = '';

  List<Bill> get items => _items;
  bool get loading => _loading;

  Future<void> load({String q = ''}) async {
    _loading = true;
    _query = q;
    notifyListeners();
    _items = await BillRepository.all(q: _query);
    _loading = false;
    notifyListeners();
  }

  Future<int> create(Bill b) async {
    final id = await BillRepository.create(b);
    await load(q: _query);
    return id;
  }

  Future<void> delete(int id) async {
    await BillRepository.delete(id);
    await load(q: _query);
  }
}
