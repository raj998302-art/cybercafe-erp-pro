import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

/// CorelDRAW-style invoice template designer (Phase 4).
/// Drag-and-drop elements onto an A4 canvas, save as JSON template,
/// and reuse for printing invoices.
class InvoiceDesignerScreen extends StatefulWidget {
  const InvoiceDesignerScreen({super.key});
  @override
  State<InvoiceDesignerScreen> createState() => _InvoiceDesignerScreenState();
}

enum _ToolType { text, image, box, line, table, signature, qr }

class _DesignElement {
  final String id;
  _ToolType type;
  double x;
  double y;
  double w;
  double h;
  String text;
  double fontSize;
  bool bold;
  String color;
  _DesignElement({
    required this.id,
    required this.type,
    this.x = 50,
    this.y = 50,
    this.w = 200,
    this.h = 40,
    this.text = '',
    this.fontSize = 14,
    this.bold = false,
    this.color = '#000000',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'x': x,
        'y': y,
        'w': w,
        'h': h,
        'text': text,
        'fontSize': fontSize,
        'bold': bold,
        'color': color,
      };

  factory _DesignElement.fromMap(Map<String, dynamic> m) => _DesignElement(
        id: m['id'] as String? ?? '',
        type: _ToolType.values.firstWhere(
          (t) => t.name == m['type'],
          orElse: () => _ToolType.text,
        ),
        x: (m['x'] as num?)?.toDouble() ?? 50,
        y: (m['y'] as num?)?.toDouble() ?? 50,
        w: (m['w'] as num?)?.toDouble() ?? 200,
        h: (m['h'] as num?)?.toDouble() ?? 40,
        text: (m['text'] ?? '') as String,
        fontSize: (m['fontSize'] as num?)?.toDouble() ?? 14,
        bold: (m['bold'] ?? false) as bool,
        color: (m['color'] ?? '#000000') as String,
      );
}

class _InvoiceDesignerScreenState extends State<InvoiceDesignerScreen> {
  final List<_DesignElement> _elements = [];
  String? _selectedId;
  String _templateName = 'My Template';
  final _nameCtrl = TextEditingController(text: 'My Template');

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  void _loadDefaults() {
    // Pre-load a default invoice layout
    _elements.addAll([
      _DesignElement(id: 't1', type: _ToolType.text, x: 40, y: 30, w: 300, h: 30,
          text: '{{company_name}}', fontSize: 22, bold: true, color: '#0F766E'),
      _DesignElement(id: 't2', type: _ToolType.text, x: 40, y: 65, w: 300, h: 20,
          text: '{{company_address}}', fontSize: 11, color: '#555555'),
      _DesignElement(id: 't3', type: _ToolType.text, x: 40, y: 110, w: 200, h: 20,
          text: 'GSTIN: {{company_gstin}}', fontSize: 11, bold: true),
      _DesignElement(id: 't4', type: _ToolType.text, x: 400, y: 30, w: 150, h: 25,
          text: 'TAX INVOICE', fontSize: 18, bold: true, color: '#0F766E'),
      _DesignElement(id: 't5', type: _ToolType.text, x: 400, y: 65, w: 150, h: 20,
          text: 'Bill No: {{bill_number}}', fontSize: 11),
      _DesignElement(id: 't6', type: _ToolType.text, x: 400, y: 90, w: 150, h: 20,
          text: 'Date: {{bill_date}}', fontSize: 11),
      _DesignElement(id: 't7', type: _ToolType.text, x: 40, y: 160, w: 300, h: 20,
          text: 'Bill To: {{customer_name}}', fontSize: 12, bold: true),
      _DesignElement(id: 't8', type: _ToolType.text, x: 40, y: 185, w: 300, h: 20,
          text: '{{customer_address}}', fontSize: 10, color: '#555555'),
      _DesignElement(id: 'b1', type: _ToolType.box, x: 40, y: 230, w: 510, h: 200,
          text: '', color: '#CCCCCC'),
      _DesignElement(id: 't9', type: _ToolType.text, x: 40, y: 450, w: 510, h: 20,
          text: 'Total: {{grand_total}} ({{amount_in_words}})', fontSize: 14, bold: true),
      _DesignElement(id: 's1', type: _ToolType.signature, x: 400, y: 540, w: 150, h: 40,
          text: 'Authorised Signatory', fontSize: 10, color: '#555555'),
    ]);
  }

  void _addTool(_ToolType type) {
    final id = 'e${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _elements.add(_DesignElement(
        id: id,
        type: type,
        x: 60,
        y: 60 + _elements.length * 10,
        text: type == _ToolType.text ? 'New Text' : '',
      ));
      _selectedId = id;
    });
  }

  void _deleteSelected() {
    if (_selectedId == null) return;
    setState(() {
      _elements.removeWhere((e) => e.id == _selectedId);
      _selectedId = null;
    });
  }

  Future<void> _saveTemplate() async {
    final json = jsonEncode({
      'name': _templateName,
      'elements': _elements.map((e) => e.toMap()).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    final exists = await DbHelper.first('settings',
        where: 'key = ?', whereArgs: ['template_$_templateName']);
    if (exists == null) {
      await DbHelper.insert('settings', {
        'key': 'template_$_templateName',
        'value': json,
      });
    } else {
      await DbHelper.update('settings', {'value': json},
          where: 'key = ?', whereArgs: ['template_$_templateName']);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template "$_templateName" saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Toolbox
          SizedBox(
            width: 180,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Designer Tools',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    _toolBtn('Text', Icons.text_fields, _ToolType.text),
                    _toolBtn('Image', Icons.image, _ToolType.image),
                    _toolBtn('Box', Icons.crop_square, _ToolType.box),
                    _toolBtn('Line', Icons.remove, _ToolType.line),
                    _toolBtn('Table', Icons.table_chart, _ToolType.table),
                    _toolBtn('Signature', Icons.draw, _ToolType.signature),
                    _toolBtn('QR Code', Icons.qr_code, _ToolType.qr),
                    const Divider(),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Template name',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => _templateName = v,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saveTemplate,
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteSelected,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete Selected',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const Divider(),
                    const Text('Variables',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('{{company_name}}\n{{company_address}}\n{{company_gstin}}\n{{bill_number}}\n{{bill_date}}\n{{customer_name}}\n{{customer_address}}\n{{grand_total}}\n{{amount_in_words}}',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Canvas
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 595, // A4 at 72dpi
                  height: 842,
                  color: Colors.white,
                  margin: const EdgeInsets.all(8),
                  child: Stack(
                    children: _elements.map((e) {
                      final selected = e.id == _selectedId;
                      return Positioned(
                        left: e.x,
                        top: e.y,
                        width: e.w,
                        height: e.h,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedId = e.id),
                          onPanUpdate: (d) {
                            setState(() {
                              e.x += d.delta.dx;
                              e.y += d.delta.dy;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selected
                                    ? Colors.teal
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: _renderElement(e),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderElement(_DesignElement e) {
    final color = _parseColor(e.color);
    switch (e.type) {
      case _ToolType.text:
      case _ToolType.signature:
        return Center(
          child: Text(
            e.text,
            style: TextStyle(
              fontSize: e.fontSize,
              fontWeight: e.bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        );
      case _ToolType.image:
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        );
      case _ToolType.box:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1),
            color: Colors.transparent,
          ),
        );
      case _ToolType.line:
        return Center(
          child: Container(height: 1, color: color),
        );
      case _ToolType.table:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: color),
          ),
          child: const Center(
            child: Text('{{items_table}}',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        );
      case _ToolType.qr:
        return Container(
          color: Colors.white,
          child: const Center(child: Icon(Icons.qr_code_2, size: 40)),
        );
    }
  }

  Color _parseColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return Colors.black;
  }

  Widget _toolBtn(String label, IconData icon, _ToolType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _addTool(type),
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
