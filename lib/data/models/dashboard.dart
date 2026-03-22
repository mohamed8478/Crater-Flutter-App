double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class DashboardStats {
  final double totalAmountDue;
  final double totalAmountOverdue;
  final double invoiceCount;
  final double estimateCount;

  DashboardStats({
    required this.totalAmountDue,
    required this.totalAmountOverdue,
    required this.invoiceCount,
    required this.estimateCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalAmountDue: _asDouble(json['total_amount_due']),
      totalAmountOverdue: _asDouble(json['total_amount_overdue']),
      invoiceCount: _asDouble(json['invoices_count']),
      estimateCount: _asDouble(json['estimates_count']),
    );
  }
}

class ChartData {
  final List<MonthlySales> incomeByMonth;
  final List<MonthlySales> expenseByMonth;

  ChartData({required this.incomeByMonth, required this.expenseByMonth});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      incomeByMonth: (json['income_by_month'] as List? ?? [])
          .map((e) => MonthlySales.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseByMonth: (json['expense_by_month'] as List? ?? [])
          .map((e) => MonthlySales.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlySales {
  final int month;
  final double total;

  MonthlySales({required this.month, required this.total});

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      month: json['month'] ?? 0,
      total: _asDouble(json['total_amount']),
    );
  }

  String get monthName {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month < names.length ? month : 0];
  }
}

class DashboardResponse {
  final DashboardStats stats;
  final ChartData chartData;
  final List<dynamic> recentInvoices;

  DashboardResponse({
    required this.stats,
    required this.chartData,
    required this.recentInvoices,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      stats: DashboardStats.fromJson(json),
      chartData: ChartData.fromJson(json),
      recentInvoices: json['recent_invoices'] as List? ?? [],
    );
  }
}
