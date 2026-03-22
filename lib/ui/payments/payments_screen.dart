import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../auth/auth_view_model.dart';
import '../widgets/crater_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_list.dart';
import '../../data/models/payment.dart';
import '../../data/services/payment_api_service.dart';
import '../../config/dependencies/injection.dart';
import 'payment_view_model.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel(
        service: Injection.get<PaymentApiService>(),
        token: authVm.token ?? '',
        companyId: authVm.companyId,
      )..load(),
      child: const _PaymentsView(),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  const _PaymentsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();

    return CraterScaffold(
      title: 'Payments',
      body: vm.loading
          ? const LoadingList()
          : vm.error != null
              ? Center(child: Text(vm.error!))
              : vm.payments.isEmpty
                  ? const EmptyState(
                      icon: Icons.credit_card_outlined,
                      title: 'No payments found',
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
                          itemCount: vm.payments.length + (vm.hasMore ? 1 : 0),
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index == vm.payments.length) {
                              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                            }
                            return _PaymentCard(payment: vm.payments[index]);
                          },
                        ),
                      ),
                    ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final currency = payment.currencySymbol ?? '\$';
    final fmt = NumberFormat('#,##0.00');
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.credit_card_outlined, color: AppColors.success, size: 20),
        ),
        title: Text(
          payment.paymentNumber,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (payment.customerName != null) ...[
              const SizedBox(height: 2),
              Text(payment.customerName!, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
            ],
            if (payment.paymentMethodName != null) ...[
              const SizedBox(height: 2),
              Text(payment.paymentMethodName!, style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
            ],
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currency${fmt.format(payment.amount)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success),
            ),
            if (payment.paymentDate != null) ...[
              const SizedBox(height: 2),
              Text(payment.paymentDate!, style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
            ],
          ],
        ),
      ),
    );
  }
}
