import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';
import '../../routing/app_router.dart';
import '../auth/auth_view_model.dart';
import '../widgets/crater_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_list.dart';
import '../widgets/status_badge.dart';
import '../../data/models/invoice.dart';
import '../../data/services/invoice_api_service.dart';
import '../../config/dependencies/injection.dart';
import 'invoice_view_model.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    return ChangeNotifierProvider(
      create: (_) => InvoiceViewModel(
        service: Injection.get<InvoiceApiService>(),
        token: authVm.token ?? '',
        companyId: authVm.companyId,
      )..load(),
      child: const _InvoicesView(),
    );
  }
}

class _InvoicesView extends StatelessWidget {
  const _InvoicesView();

  static const _tabs = ['ALL', 'DRAFT', 'SENT', 'DUE'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceViewModel>();

    return CraterScaffold(
      title: 'Invoices',
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push<bool>(AppRoutes.invoiceCreate);
          if (created == true) vm.load();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.surface,
            child: DefaultTabController(
              length: _tabs.length,
              initialIndex: _tabs.indexOf(vm.activeTab),
              child: TabBar(
                tabs: _tabs
                    .map((t) => Tab(text: t == 'ALL' ? 'All' : _capitalize(t)))
                    .toList(),
                onTap: (i) => vm.setTab(_tabs[i]),
              ),
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
                    : vm.invoices.isEmpty
                        ? EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No invoices found',
                            subtitle: 'Get started by creating your first invoice.',
                            buttonLabel: 'Add New Invoice',
                            onButtonPressed: () async {
                              final created = await context.push<bool>(AppRoutes.invoiceCreate);
                              if (created == true) vm.load();
                            },
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
                                itemCount: vm.invoices.length + (vm.hasMore ? 1 : 0),
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  if (index == vm.invoices.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return _InvoiceCard(invoice: vm.invoices[index]);
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0] + s.substring(1).toLowerCase();
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final currency = invoice.currencySymbol ?? '\$';
    final fmt = NumberFormat('#,##0.00');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary500,
                        ),
                      ),
                      if (invoice.customerName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          invoice.customerName!,
                          style: const TextStyle(fontSize: 13, color: AppColors.slate500),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currency${fmt.format(invoice.total)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                      ),
                    ),
                    if (invoice.dueAmount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Due: $currency${fmt.format(invoice.dueAmount)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.danger),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StatusBadge.fromInvoiceStatus(invoice.status),
                const SizedBox(width: 6),
                StatusBadge.fromPaidStatus(invoice.paidStatus),
                if (invoice.overdue) ...[
                  const SizedBox(width: 6),
                  const StatusBadge(
                    label: 'OVERDUE',
                    backgroundColor: Color(0xFFFEE2E2),
                    textColor: Color(0xFFDC2626),
                  ),
                ],
                const Spacer(),
                if (invoice.invoiceDate != null)
                  Text(
                    invoice.invoiceDate!,
                    style: const TextStyle(fontSize: 11, color: AppColors.slate400),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
