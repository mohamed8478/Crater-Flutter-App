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
import '../../data/models/estimate.dart';
import '../../data/services/estimate_api_service.dart';
import '../../config/dependencies/injection.dart';
import 'estimate_view_model.dart';

class EstimatesScreen extends StatelessWidget {
  const EstimatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    return ChangeNotifierProvider(
      create: (_) => EstimateViewModel(
        service: Injection.get<EstimateApiService>(),
        token: authVm.token ?? '',
        companyId: authVm.companyId,
      )..load(),
      child: const _EstimatesView(),
    );
  }
}

class _EstimatesView extends StatefulWidget {
  const _EstimatesView();

  @override
  State<_EstimatesView> createState() => _EstimatesViewState();
}

class _EstimatesViewState extends State<_EstimatesView>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['ALL', 'DRAFT', 'SENT', 'ACCEPTED', 'REJECTED'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _cap(String s) => s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EstimateViewModel>();

    return CraterScaffold(
      title: 'Estimates',
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push<bool>(AppRoutes.estimateCreate);
          if (created == true) vm.load();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              tabs: _tabs
                  .map((t) => Tab(text: t == 'ALL' ? 'All' : _cap(t)))
                  .toList(),
              onTap: (i) => vm.setTab(_tabs[i]),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: vm.loading
                ? const LoadingList()
                : vm.error != null
                    ? Center(child: Text(vm.error!))
                    : vm.estimates.isEmpty
                        ? const EmptyState(
                            icon: Icons.description_outlined,
                            title: 'No estimates found',
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.pixels >=
                                  n.metrics.maxScrollExtent - 200) {
                                vm.loadMore();
                              }
                              return false;
                            },
                            child: RefreshIndicator(
                              onRefresh: () => vm.load(),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount:
                                    vm.estimates.length + (vm.hasMore ? 1 : 0),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  if (index == vm.estimates.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return _EstimateCard(
                                      estimate: vm.estimates[index]);
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

class _EstimateCard extends StatelessWidget {
  final Estimate estimate;

  const _EstimateCard({required this.estimate});

  @override
  Widget build(BuildContext context) {
    final currency = estimate.currencySymbol ?? '\$';
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
                        estimate.estimateNumber,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary500),
                      ),
                      if (estimate.customerName != null) ...[
                        const SizedBox(height: 2),
                        Text(estimate.customerName!,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.slate500)),
                      ],
                    ],
                  ),
                ),
                Text(
                  '$currency${fmt.format(estimate.total)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StatusBadge.fromEstimateStatus(estimate.status),
                const Spacer(),
                if (estimate.estimateDate != null)
                  Text(estimate.estimateDate!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.slate400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
