import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../data/models/unit.dart';
import '../../data/services/item_api_service.dart';

class ItemFormScreen extends StatefulWidget {
  final ItemApiService service;
  final String token;
  final int? companyId;

  const ItemFormScreen({
    super.key,
    required this.service,
    required this.token,
    this.companyId,
  });

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Unit> _units = [];
  int? _selectedUnitId;
  bool _saving = false;
  bool _loadingUnits = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      _units = await widget.service.getUnits(widget.token, companyId: widget.companyId);
    } catch (_) {}
    if (mounted) setState(() => _loadingUnits = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final price = double.tryParse(_priceController.text) ?? 0;
      final data = {
        'name': _nameController.text.trim(),
        'price': (price * 100).round(),
        if (_descriptionController.text.trim().isNotEmpty) 'description': _descriptionController.text.trim(),
        if (_selectedUnitId != null) 'unit_id': _selectedUnitId,
      };
      await widget.service.createItem(widget.token, data, companyId: widget.companyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item created successfully')));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
        actions: [
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price *', prefixText: '\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _loadingUnits
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<int?>(
                    initialValue: _selectedUnitId,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('None')),
                      ..._units.map((u) => DropdownMenuItem<int?>(value: u.id, child: Text(u.name))),
                    ],
                    onChanged: (v) => setState(() => _selectedUnitId = v),
                  ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
