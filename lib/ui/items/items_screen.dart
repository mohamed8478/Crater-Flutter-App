import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/dependencies/injection.dart';
import '../../config/theme/app_colors.dart';
import '../../data/services/item_api_service.dart';
import '../../routing/app_router.dart';
import '../../ui/auth/auth_view_model.dart';
import '../../ui/widgets/crater_app_bar.dart';
import '../../ui/widgets/empty_state.dart';
import 'item_view_model.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    return ChangeNotifierProvider(
      create: (_) => ItemViewModel(
        service: Injection.get<ItemApiService>(),
        token: authVm.token ?? '',
        companyId: authVm.companyId,
      )..load(),
      child: const _ItemsView(),
    );
  }
}

class _ItemsView extends StatelessWidget {
  const _ItemsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemViewModel>();
    return CraterScaffold(
      title: 'Items',
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push<bool>(AppRoutes.itemCreate);
          if (created == true) vm.load();
        },
        child: const Icon(Icons.add),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.error!, style: const TextStyle(color: AppColors.danger)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: vm.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : vm.items.isEmpty
                  ? EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No Items',
                      subtitle: 'Create your first item to get started.',
                      buttonLabel: 'Add Item',
                      onButtonPressed: () async {
                        final created = await context.push<bool>(AppRoutes.itemCreate);
                        if (created == true) vm.load();
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: vm.load,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scroll) {
                          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 && vm.hasMore) {
                            vm.loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.items.length,
                          itemBuilder: (context, index) {
                            final item = vm.items[index];
                            return _ItemCard(
                              item: item,
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Item'),
                                    content: Text('Delete "${item.name}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) vm.deleteItem(item.id);
                              },
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onDelete;

  const _ItemCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: item.description != null ? Text(item.description!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary500),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
