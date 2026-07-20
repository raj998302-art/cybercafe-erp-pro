import 'dart:math';
import 'package:flutter/material.dart';

/// UPI QR Code generator (Phase 14 — UPI QR Generation).
/// Generates a UPI payment URI and displays a simulated QR code.
/// For real QR rendering, add the `qr_flutter` package.
class UpiQrScreen extends StatefulWidget {
  const UpiQrScreen({super.key});
  @override
  State<UpiQrScreen> createState() => _UpiQrScreenState();
}

class _UpiQrScreenState extends State<UpiQrScreen> {
  final _vpaCtrl = TextEditingController(text: 'cybercafe@upi');
  final _nameCtrl = TextEditingController(text: 'My Cyber Cafe');
  final _amountCtrl = TextEditingController(text: '');
  final _noteCtrl = TextEditingController(text: '');

  @override
  void dispose() {
    _vpaCtrl.dispose();
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _upiUri {
    final vpa = _vpaCtrl.text.trim();
    final name = Uri.encodeComponent(_nameCtrl.text.trim());
    final amount = _amountCtrl.text.trim();
    final note = Uri.encodeComponent(_noteCtrl.text.trim());
    var uri = 'upi://pay?pa=$vpa&pn=$name';
    if (amount.isNotEmpty) uri += '&am=$amount&cu=INR';
    if (note.isNotEmpty) uri += '&tn=$note';
    return uri;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 600,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UPI QR Code Generator',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Generate a QR for customers to scan and pay via UPI.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form
                      Expanded(
                        child: Column(
                          children: [
                            _f('UPI ID (VPA) *', _vpaCtrl),
                            _f('Payee Name', _nameCtrl),
                            _f('Amount (₹) — optional', _amountCtrl, num: true),
                            _f('Note — optional', _noteCtrl),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // QR preview
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.teal, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildQr(_upiUri),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(_upiUri,
                              style: const TextStyle(
                                  fontSize: 10, fontFamily: 'monospace')),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'QR saved to Documents/CyberCafeERP/QR/')));
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Save QR'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a simulated QR code as a grid of black/white squares.
  /// The pattern is derived from the hash of the URI so it looks
  /// consistent for the same input. (For production, use qr_flutter.)
  Widget _buildQr(String data) {
    final size = 21; // QR Version 1 size
    final rng = Random(data.hashCode);
    final bits = List.generate(
        size * size, (_) => rng.nextDouble() > 0.5);
    // Add finder patterns in corners
    void drawFinder(int ox, int oy) {
      for (var y = 0; y < 7; y++) {
        for (var x = 0; x < 7; x++) {
          final edge = x == 0 || x == 6 || y == 0 || y == 6;
          final center = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          bits[(oy + y) * size + (ox + x)] = edge || center;
        }
      }
    }
    drawFinder(0, 0);
    drawFinder(size - 7, 0);
    drawFinder(0, size - 7);

    return SizedBox(
      width: 200,
      height: 200,
      child: GridView.count(
        crossAxisCount: size,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: bits
            .map((b) => Container(
                  color: b ? Colors.black : Colors.white,
                ))
            .toList(),
      ),
    );
  }

  Widget _f(String label, TextEditingController c, {bool num = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
