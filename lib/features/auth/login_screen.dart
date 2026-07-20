import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/db_helper.dart';

/// Login screen (Phase 12 — Security).
/// Uses a local PIN/password stored in settings table.
/// Default PIN: 1234 (changeable from settings).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ensureDefaultPin();
  }

  Future<void> _ensureDefaultPin() async {
    final row = await DbHelper.first('settings', where: 'key = ?', whereArgs: ['app_pin']);
    if (row == null) {
      await DbHelper.insert('settings', {'key': 'app_pin', 'value': '1234'});
    }
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final row = await DbHelper.first('settings', where: 'key = ?', whereArgs: ['app_pin']);
    final storedPin = row?['value'] as String? ?? '1234';
    await Future.delayed(const Duration(milliseconds: 300));
    if (_pinCtrl.text == storedPin) {
      if (mounted) context.go('/');
    } else {
      setState(() {
        _error = 'Wrong PIN. Try again. (Default: 1234)';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 380,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('CyberCafe ERP Pro',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Enter your PIN to continue',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pinCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '••••',
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Default PIN is 1234. Change it in Settings.')),
                      );
                    },
                    child: const Text('Forgot PIN?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
