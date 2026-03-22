import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../data/models/line_item.dart';

class LineItemRow extends StatelessWidget {
  final LineItem item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onSelectItem;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;

  const LineItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onSelectItem,
    required this.onNameChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Item #${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onSelectItem,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  item.name.isEmpty ? 'Select or type item' : item.name,
                  style: TextStyle(
                    color: item.name.isEmpty ? AppColors.slate400 : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final qty = int.tryParse(v) ?? 1;
                      onQuantityChanged(qty);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item.price > 0 ? item.price.toStringAsFixed(2) : '',
                    decoration: const InputDecoration(labelText: 'Price', prefixText: '\$ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) {
                      final price = double.tryParse(v) ?? 0;
                      onPriceChanged(price);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
