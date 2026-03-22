import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomerPicker extends StatefulWidget {
  final List<dynamic> customers;
  final ValueChanged<dynamic> onSelected;

  const CustomerPicker({
    super.key,
    required this.customers,
    required this.onSelected,
  });

  static Future<void> show(BuildContext context, {
    required List<dynamic> customers,
    required ValueChanged<dynamic> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => CustomerPicker(
          customers: customers,
          onSelected: (c) {
            onSelected(c);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  State<CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<CustomerPicker> {
  final _searchController = TextEditingController();
  List<dynamic> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.customers;
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.customers;
      } else {
        final q = query.toLowerCase();
        _filtered = widget.customers.where((c) {
          final name = (c.name ?? '').toLowerCase();
          return name.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filter,
              ),
            ],
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No customers found'))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final customer = _filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary100,
                        child: Text(
                          (customer.name ?? 'C')[0].toUpperCase(),
                          style: const TextStyle(color: AppColors.primary600, fontWeight: FontWeight.w600),
                        ),
                      ),
                      title: Text(customer.name ?? ''),
                      onTap: () => widget.onSelected(customer),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
