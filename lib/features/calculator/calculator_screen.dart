import 'package:flutter/material.dart';

/// Built-in calculator (Phase 14 — advanced tools).
/// Big buttons, friendly for the older shop owner.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expr = '';
  double? _prev;
  String? _op;

  void _input(String s) {
    setState(() {
      if (s == 'C') {
        _display = '0';
        _expr = '';
        _prev = null;
        _op = null;
        return;
      }
      if (s == '⌫') {
        _display = _display.length > 1
            ? _display.substring(0, _display.length - 1)
            : '0';
        return;
      }
      if (s == '=') {
        _calc();
        return;
      }
      if (['+', '-', '×', '÷'].contains(s)) {
        if (_op != null && _prev != null) _calc();
        _prev = double.tryParse(_display) ?? 0;
        _op = s;
        _expr = '$_prev $s ';
        _display = '0';
        return;
      }
      if (s == '%') {
        final v = double.tryParse(_display) ?? 0;
        _display = (v / 100).toString();
        return;
      }
      if (s == '.') {
        if (!_display.contains('.')) _display += '.';
        return;
      }
      _display = _display == '0' ? s : _display + s;
    });
  }

  void _calc() {
    if (_prev == null || _op == null) return;
    final curr = double.tryParse(_display) ?? 0;
    double res = 0;
    switch (_op) {
      case '+':
        res = _prev! + curr;
        break;
      case '-':
        res = _prev! - curr;
        break;
      case '×':
        res = _prev! * curr;
        break;
      case '÷':
        res = curr == 0 ? 0 : _prev! / curr;
        break;
    }
    _expr = '$_prev $_op $curr =';
    _display = res == res.roundToDouble()
        ? res.toStringAsFixed(0)
        : res.toStringAsFixed(2);
    _prev = null;
    _op = null;
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      'C', '⌫', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '0', '.', '=',
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_expr,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                        Text(_display,
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: keys.length,
                    itemBuilder: (context, i) {
                      final k = keys[i];
                      final isOp = ['÷', '×', '-', '+', '='].contains(k);
                      final isFn = ['C', '⌫', '%'].contains(k);
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: k == '='
                              ? Colors.teal
                              : isOp
                                  ? Colors.teal.shade100
                                  : isFn
                                      ? Colors.orange.shade100
                                      : Colors.white,
                          foregroundColor: k == '='
                              ? Colors.white
                              : isOp
                                  ? Colors.teal.shade800
                                  : isFn
                                      ? Colors.orange.shade800
                                      : Colors.black87,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => _input(k),
                        child: Text(k, style: const TextStyle(fontSize: 22)),
                      );
                    },
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
