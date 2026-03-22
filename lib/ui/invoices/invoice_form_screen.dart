import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../config/theme/app_colors.dart';
import '../../data/models/customer.dart';
import '../../data/models/item.dart';
import '../../data/models/line_item.dart';
import '../../data/models/invoice_draft.dart';
import '../../data/services/invoice_api_service.dart';
import '../../data/services/customer_api_service.dart';
import '../../data/services/item_api_service.dart';
import '../../routing/app_router.dart';
import 'models/invoice_preview_args.dart';
import 'invoice_preview_generator.dart';
import '../widgets/customer_picker.dart';
import '../widgets/item_picker.dart';

class InvoiceFormScreen extends StatefulWidget {
  final InvoiceApiService invoiceService;
  final CustomerApiService customerService;
  final ItemApiService itemService;
  final String token;
  final int? companyId;
  final InvoiceDraft? draft;
  final File? scanFile;
  final XFile? xFile;

  const InvoiceFormScreen({
    super.key,
    required this.invoiceService,
    required this.customerService,
    required this.itemService,
    required this.token,
    this.companyId,
    this.draft,
    this.scanFile,
    this.xFile,
  });

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _previewing = false;
  String? _error;
  File? _scanFile;
  XFile? _xFile;
  String? _draftRawText;

  String _invoiceNumber = '';
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  Customer? _selectedCustomer;
  final List<LineItem> _lineItems = [];

  List<Customer> _customers = [];
  List<Item> _catalogItems = [];

  @override
  void initState() {
    super.initState();
    _scanFile = widget.scanFile;
    _xFile = widget.xFile;
    _draftRawText = widget.draft?.rawText;
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final results = await Future.wait([
        widget.customerService.getCustomers(widget.token, companyId: widget.companyId),
        widget.itemService.getItems(widget.token, companyId: widget.companyId),
        widget.invoiceService.getNextNumber(widget.token, companyId: widget.companyId),
      ]);
      _customers = (results[0] as CustomerListResponse).customers;
      _catalogItems = (results[1] as ItemListResponse).items;
      _invoiceNumber = results[2] as String;
      if (widget.draft != null) {
        _applyDraft(widget.draft!);
      } else {
        _lineItems.add(LineItem());
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyDraft(InvoiceDraft draft) {
    if (draft.invoiceNumber != null && draft.invoiceNumber!.isNotEmpty) {
      _invoiceNumber = draft.invoiceNumber!;
    }
    if (draft.invoiceDate != null) {
      _invoiceDate = draft.invoiceDate!;
    }
    if (draft.dueDate != null) {
      _dueDate = draft.dueDate;
    }
    if (draft.notes != null && draft.notes!.isNotEmpty) {
      _notesController.text = draft.notes!;
    }

    final matchedCustomer = _resolveDraftCustomer(draft);
    if (matchedCustomer != null) {
      _selectedCustomer = matchedCustomer;
    }

    _lineItems
      ..clear()
      ..addAll(
        draft.lineItems.isNotEmpty
            ? draft.lineItems.map(_cloneLineItem)
            : [LineItem()],
      );
  }

  Customer? _resolveDraftCustomer(InvoiceDraft draft) {
    if (draft.customerId != null) {
      return _customers.firstWhereOrNull((c) => c.id == draft.customerId);
    }
    if (draft.customerName != null) {
      final name = draft.customerName!.toLowerCase();
      return _customers.firstWhereOrNull((c) => c.name.toLowerCase() == name);
    }
    return null;
  }

  LineItem _cloneLineItem(LineItem source) {
    final cloned = LineItem(
      itemId: source.itemId,
      name: source.name,
      quantity: source.quantity,
      price: source.price,
      description: source.description,
      unitName: source.unitName,
    )
      ..discountType = source.discountType
      ..discount = source.discount
      ..discountVal = source.discountVal
      ..tax = source.tax;
    cloned.recalculate();
    return cloned;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _subTotal => _lineItems.fold(0.0, (sum, i) => sum + (i.quantity * i.price));
  double get _totalTax => _lineItems.fold(0.0, (sum, i) => sum + i.tax);
  double get _total => _subTotal + _totalTax;

  void _addLineItem() {
    setState(() => _lineItems.add(LineItem()));
  }

  void _removeLineItem(int index) {
    setState(() => _lineItems.removeAt(index));
  }

  void _selectCatalogItem(int lineIndex, Item catalogItem) {
    setState(() {
      _lineItems[lineIndex]
        ..itemId = catalogItem.id
        ..name = catalogItem.name
        ..price = catalogItem.price
        ..description = catalogItem.description
        ..unitName = catalogItem.unitName;
      _lineItems[lineIndex].recalculate();
    });
  }

  void _updateQuantity(int index, int qty) {
    setState(() {
      _lineItems[index].quantity = qty;
      _lineItems[index].recalculate();
    });
  }

  void _updatePrice(int index, double price) {
    setState(() {
      _lineItems[index].price = price;
      _lineItems[index].recalculate();
    });
  }

  Future<void> _preview() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer before previewing'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_lineItems.isEmpty || _lineItems.every((i) => i.name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one line item to preview'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _previewing = true);
    try {
      // Generate preview locally instead of API call
      final html = InvoicePreviewGenerator.generate(
        invoiceNumber: _invoiceNumber,
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        customer: _selectedCustomer,
        lineItems: _lineItems,
        subTotal: _subTotal,
        tax: _totalTax,
        total: _total,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (!mounted) return;
      await context.push(
        AppRoutes.invoicePreview,
        extra: InvoicePreviewArgs(html: html, title: _invoiceNumber),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to build preview: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'invoice_date': DateFormat('yyyy-MM-dd').format(_invoiceDate),
      if (_dueDate != null) 'due_date': DateFormat('yyyy-MM-dd').format(_dueDate!),
      'invoice_number': _invoiceNumber,
      'customer_id': _selectedCustomer?.id,
      'discount': 0,
      'discount_type': 'fixed',
      'discount_val': 0,
      'sub_total': (_subTotal * 100).round(),
      'total': (_total * 100).round(),
      'tax': (_totalTax * 100).round(),
      'template_name': 'invoice1',
      'items': _lineItems.where((i) => i.name.isNotEmpty).map((i) => i.toJson()).toList(),
      'exchange_rate': 1,
      if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
    };
  }

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPicked) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) onPicked(date);
  }

  Future<void> _save() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_lineItems.isEmpty || _lineItems.every((i) => i.name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final payload = _buildPayload();
      final response = await widget.invoiceService.createInvoice(
        widget.token,
        payload,
        companyId: widget.companyId,
      );

      final invoiceId = _extractInvoiceId(response);

      // Attach scan file if available
      if (invoiceId != null) {
        final metadata = _draftRawText != null ? {'raw_text': _draftRawText} : null;

        if (kIsWeb && _xFile != null) {
          // Use XFile for web platform
          await widget.invoiceService.attachScanFromXFile(
            widget.token,
            invoiceId,
            _xFile!,
            companyId: widget.companyId,
            metadata: metadata,
          );
        } else if (_scanFile != null) {
          // Use File for native platforms
          await widget.invoiceService.attachScan(
            widget.token,
            invoiceId,
            _scanFile!,
            companyId: widget.companyId,
            metadata: metadata,
          );
        }
      }

      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice created successfully')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Invoice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Invoice')),
        body: Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
        actions: [
          if (_previewing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'Preview',
              onPressed: _saving ? null : _preview,
            ),
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                )
              : TextButton(onPressed: _save, child: const Text('Save', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Invoice Number
            TextFormField(
              initialValue: _invoiceNumber,
              decoration: const InputDecoration(labelText: 'Invoice Number'),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(_invoiceDate, (d) => setState(() => _invoiceDate = d)),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Invoice Date *'),
                      child: Text(DateFormat('yyyy-MM-dd').format(_invoiceDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(_dueDate ?? DateTime.now().add(const Duration(days: 30)), (d) => setState(() => _dueDate = d)),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Due Date'),
                      child: Text(_dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : 'Select'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer
            InkWell(
              onTap: () => CustomerPicker.show(
                context,
                customers: _customers,
                onSelected: (c) => setState(() => _selectedCustomer = c as Customer),
              ),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Customer *',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selectedCustomer?.name ?? 'Select Customer',
                  style: TextStyle(color: _selectedCustomer == null ? AppColors.slate400 : null),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Line Items
            Row(
              children: [
                const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addLineItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._lineItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildLineItemCard(index, item);
            }),

            const SizedBox(height: 16),

            // Totals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _totalRow('Sub Total', _subTotal),
                    const Divider(),
                    _totalRow('Tax', _totalTax),
                    const Divider(),
                    _totalRow('Total', _total, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemCard(int index, LineItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Item #${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_lineItems.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                    onPressed: () => _removeLineItem(index),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => ItemPicker.show(
                context,
                items: _catalogItems,
                onSelected: (catalogItem) => _selectCatalogItem(index, catalogItem),
              ),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Item Name', suffixIcon: Icon(Icons.arrow_drop_down)),
                child: Text(
                  item.name.isEmpty ? 'Select item' : item.name,
                  style: TextStyle(color: item.name.isEmpty ? AppColors.slate400 : null),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('qty_$index'),
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _updateQuantity(index, int.tryParse(v) ?? 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    key: ValueKey('price_${index}_${item.itemId}'),
                    initialValue: item.price > 0 ? item.price.toStringAsFixed(2) : '',
                    decoration: const InputDecoration(labelText: 'Price', prefixText: '\$ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => _updatePrice(index, double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14),
          ),
        ],
      ),
    );
  }

  int? _extractInvoiceId(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      if (data['invoice'] is Map<String, dynamic>) {
        return (data['invoice']['id'] as num?)?.toInt();
      }
      return (data['id'] as num?)?.toInt();
    }
    if (response['invoice'] is Map<String, dynamic>) {
      return (response['invoice']['id'] as num?)?.toInt();
    }
    return (response['id'] as num?)?.toInt();
  }
}
