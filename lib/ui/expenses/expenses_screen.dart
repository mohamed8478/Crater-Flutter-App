import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../auth/auth_view_model.dart';
import '../widgets/crater_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_list.dart';
import '../../data/models/expense.dart';
import '../../data/services/expense_api_service.dart';
import '../../config/dependencies/injection.dart';
import 'expense_view_model.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    return ChangeNotifierProvider(
      create: (_) => ExpenseViewModel(
        service: Injection.get<ExpenseApiService>(),
        token: authVm.token ?? '',
        companyId: authVm.companyId,
      )..load(),
      child: const _ExpensesView(),
    );
  }
}

class _ExpensesView extends StatelessWidget {
  const _ExpensesView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();

    return CraterScaffold(
      title: 'Expenses',
      body: vm.loading
          ? const LoadingList()
          : vm.error != null
              ? Center(child: Text(vm.error!))
              : vm.expenses.isEmpty
                  ? const EmptyState(
                      icon: Icons.calculate_outlined,
                      title: 'No expenses found',
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
                          itemCount: vm.expenses.length + (vm.hasMore ? 1 : 0),
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index == vm.expenses.length) {
                              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                            }
                            return _ExpenseCard(expense: vm.expenses[index]);
                          },
                        ),
                      ),
                    ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final currency = expense.currencySymbol ?? '\$';
    final fmt = NumberFormat('#,##0.00');
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.calculate_outlined, color: AppColors.warning, size: 20),
        ),
        title: Text(
          expense.categoryName ?? 'Expense',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate800),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.customerName != null) ...[
              const SizedBox(height: 2),
              Text(expense.customerName!, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
            ],
            if (expense.notes != null && expense.notes!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(expense.notes!, style: const TextStyle(fontSize: 11, color: AppColors.slate400), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currency${fmt.format(expense.amount)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning),
            ),
            if (expense.expenseDate != null) ...[
              const SizedBox(height: 2),
              Text(expense.expenseDate!, style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
            ],
          ],
        ),
      ),
    );
  }
}
