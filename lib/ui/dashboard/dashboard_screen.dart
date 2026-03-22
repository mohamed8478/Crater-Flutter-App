import '../../data/models/parsers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../auth/auth_view_model.dart';
import '../widgets/crater_app_bar.dart';
import 'dashboard_view_model.dart';
import '../../data/services/dashboard_api_service.dart';
import '../../config/dependencies/injection.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(
        service: Injection.get<DashboardApiService>(),
        token: authVm.token ?? '',
        companyId: authVm.companyId,
      )..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return CraterScaffold(
      title: 'Dashboard',
      body: vm.initialLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? _ErrorWidget(error: vm.error!, onRetry: () => vm.load())
              : RefreshIndicator(
                  onRefresh: () => vm.refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (vm.data != null) ...[
                          _StatsRow(stats: vm.data!.stats, loading: vm.loading),
                          const SizedBox(height: 20),
                          _ChartCard(chartData: vm.data!.chartData, loading: vm.loading),
                          const SizedBox(height: 20),
                          _RecentInvoicesCard(invoices: vm.data!.recentInvoices, loading: vm.loading),
                        ] else ...[
                          _StatsSkeletonLoader(),
                          const SizedBox(height: 20),
                          _ChartSkeletonLoader(),
                          const SizedBox(height: 20),
                          _InvoicesSkeletonLoader(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.slate600)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// Skeleton loaders for progressive loading
class _StatsSkeletonLoader extends StatelessWidget {
  const _StatsSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(
        4,
        (_) => Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 12, width: 60, decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(4))),
                Container(height: 20, width: 80, decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartSkeletonLoader extends StatelessWidget {
  const _ChartSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 15, width: 100, decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            Container(height: 180, decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(8))),
          ],
        ),
      ),
    );
  }
}

class _InvoicesSkeletonLoader extends StatelessWidget {
  const _InvoicesSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Recent Invoices', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 120, decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 80, decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic stats;
  final bool loading;

  const _StatsRow({required this.stats, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          label: 'Amount Due',
          value: currency.format(stats.totalAmountDue),
          icon: Icons.receipt_long_outlined,
          color: AppColors.primary500,
        ),
        _StatCard(
          label: 'Amount Overdue',
          value: currency.format(stats.totalAmountOverdue),
          icon: Icons.warning_amber_outlined,
          color: AppColors.danger,
        ),
        _StatCard(
          label: 'Invoices',
          value: stats.invoiceCount.toInt().toString(),
          icon: Icons.description_outlined,
          color: AppColors.info,
        ),
        _StatCard(
          label: 'Estimates',
          value: stats.estimateCount.toInt().toString(),
          icon: Icons.summarize_outlined,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final dynamic chartData;
  final bool loading;

  const _ChartCard({required this.chartData, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Overview',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.slate700),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _Legend(color: AppColors.primary500, label: 'Income'),
                const SizedBox(width: 16),
                _Legend(color: AppColors.danger, label: 'Expenses'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        const FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, meta) => Text(
                          '\$${(v / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(fontSize: 10, color: AppColors.slate400),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          final months = chartData.incomeByMonth;
                          if (idx < 0 || idx >= months.length) return const SizedBox();
                          return Text(
                            months[idx].monthName,
                            style: const TextStyle(fontSize: 10, color: AppColors.slate400),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Income line
                    LineChartBarData(
                      spots: List.generate(
                        chartData.incomeByMonth.length,
                        (i) => FlSpot(i.toDouble(), chartData.incomeByMonth[i].total),
                      ),
                      isCurved: true,
                      color: AppColors.primary500,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary500.withAlpha(25),
                      ),
                    ),
                    // Expense line
                    LineChartBarData(
                      spots: List.generate(
                        chartData.expenseByMonth.length,
                        (i) => FlSpot(i.toDouble(), chartData.expenseByMonth[i].total),
                      ),
                      isCurved: true,
                      color: AppColors.danger,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.danger.withAlpha(20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
      ],
    );
  }
}

class _RecentInvoicesCard extends StatelessWidget {
  final List<dynamic> invoices;
  final bool loading;

  const _RecentInvoicesCard({required this.invoices, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recent Invoices',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.slate700),
            ),
          ),
          if (invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No recent invoices', style: TextStyle(color: AppColors.slate400)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final inv = invoices[index] as Map<String, dynamic>;
                final total = parseAmount(inv['total']);
                final currency = inv['currency']?['symbol'] ?? '\$';
                final status = inv['status'] ?? 'DRAFT';
                return ListTile(
                  title: Text(
                    inv['invoice_number'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary500,
                    ),
                  ),
                  subtitle: Text(
                    inv['customer']?['name'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate400),
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$currency${NumberFormat('#,##0.00').format(total)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _statusBadge(status),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color text;
    switch (status.toUpperCase()) {
      case 'DRAFT':
        bg = AppColors.slate100;
        text = AppColors.slate600;
        break;
      case 'SENT':
        bg = const Color(0xFFDCEFFD);
        text = AppColors.info;
        break;
      case 'DUE':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        break;
      case 'COMPLETED':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF059669);
        break;
      default:
        bg = AppColors.slate100;
        text = AppColors.slate600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: text),
      ),
    );
  }
}
