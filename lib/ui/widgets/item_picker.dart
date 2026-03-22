import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../data/models/item.dart';

class ItemPicker extends StatefulWidget {
  final List<Item> items;
  final ValueChanged<Item> onSelected;

  const ItemPicker({
    super.key,
    required this.items,
    required this.onSelected,
  });

  static Future<void> show(BuildContext context, {
    required List<Item> items,
    required ValueChanged<Item> onSelected,
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
        builder: (context, scrollController) => ItemPicker(
          items: items,
          onSelected: (item) {
            onSelected(item);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  State<ItemPicker> createState() => _ItemPickerState();
}

class _ItemPickerState extends State<ItemPicker> {
  final _searchController = TextEditingController();
  List<Item> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.items;
      } else {
        final q = query.toLowerCase();
        _filtered = widget.items.where((i) => i.name.toLowerCase().contains(q)).toList();
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
              const Text('Select Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filter,
              ),
            ],
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No items found'))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final item = _filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary100,
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary600, size: 18),
                      ),
                      title: Text(item.name),
                      trailing: Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary500),
                      ),
                      subtitle: item.description != null ? Text(item.description!, maxLines: 1) : null,
                      onTap: () => widget.onSelected(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
