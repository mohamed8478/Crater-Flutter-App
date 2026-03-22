import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../auth/auth_view_model.dart';
import '../widgets/crater_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_list.dart';
import '../../data/models/customer.dart';
import '../../data/services/customer_api_service.dart';
import '../../config/dependencies/injection.dart';
import 'customer_view_model.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    return ChangeNotifierProvider(
      create: (_) => CustomerViewModel(
        service: Injection.get<CustomerApiService>(),
        token: authVm.token ?? '',
        companyId: authVm.companyId,
      )..load(),
      child: const _CustomersView(),
    );
  }
}

class _CustomersView extends StatefulWidget {
  const _CustomersView();

  @override
  State<_CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<_CustomersView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerViewModel>();

    return CraterScaffold(
      title: 'Customers',
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddCustomerScreen.show(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search, color: AppColors.slate400, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          vm.search('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (v) => vm.search(v),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: vm.loading
                ? const LoadingList()
                : vm.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
                            const SizedBox(height: 8),
                            Text(vm.error!, textAlign: TextAlign.center),
                            TextButton(onPressed: () => vm.load(), child: const Text('Retry')),
                          ],
                        ),
                      )
                    : vm.customers.isEmpty
                        ? const EmptyState(
                            icon: Icons.person_outline,
                            title: 'No customers found',
                            subtitle: 'Add your first customer to get started.',
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                                vm.loadMore();
                              }
                              return false;
                            },
                            child: RefreshIndicator(
                              onRefresh: () => vm.load(),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: vm.customers.length + (vm.hasMore ? 1 : 0),
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  if (index == vm.customers.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return _CustomerCard(customer: vm.customers[index]);
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final currency = customer.currencySymbol ?? '\$';
    final fmt = NumberFormat('#,##0.00');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary100,
          child: Text(
            customer.initials,
            style: const TextStyle(
              color: AppColors.primary600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.contactName != null && customer.contactName!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                customer.contactName!,
                style: const TextStyle(fontSize: 12, color: AppColors.slate400),
              ),
            ],
            if (customer.phone != null && customer.phone!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.phone, size: 12, color: AppColors.slate400),
                  const SizedBox(width: 4),
                  Text(
                    customer.phone!,
                    style: const TextStyle(fontSize: 12, color: AppColors.slate400),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Due',
              style: const TextStyle(fontSize: 11, color: AppColors.slate400),
            ),
            Text(
              '$currency${fmt.format(customer.dueAmount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: customer.dueAmount > 0 ? AppColors.danger : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
