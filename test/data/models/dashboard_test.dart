import 'package:flutter_test/flutter_test.dart';
import 'package:crater_app/data/models/dashboard.dart';

void main() {
  test('DashboardStats handles string values', () {
    final stats = DashboardStats.fromJson({
      'total_amount_due': '120000',
      'total_amount_overdue': '50000',
      'invoices_count': '3',
      'estimates_count': '2',
    });

    expect(stats.totalAmountDue, 120000);
    expect(stats.totalAmountOverdue, 50000);
    expect(stats.invoiceCount, 3);
    expect(stats.estimateCount, 2);
  });

  test('MonthlySales handles string totals', () {
    final sale = MonthlySales.fromJson({
      'month': 1,
      'total_amount': '10000',
    });

    expect(sale.month, 1);
    expect(sale.total, 10000);
  });
}
