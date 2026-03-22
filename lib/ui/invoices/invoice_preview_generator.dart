import 'package:intl/intl.dart';

import '../../data/models/customer.dart';
import '../../data/models/invoice.dart';
import '../../data/models/line_item.dart';

/// Generates HTML preview for invoices locally without requiring API call
class InvoicePreviewGenerator {
  /// Generate preview from an existing Invoice object
  static String generateFromInvoice(Invoice invoice) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final numberFormat = NumberFormat('#,##0.00');
    final currencySymbol = invoice.currencySymbol ?? '\$';

    final itemsHtml = invoice.items.map((item) {
      return '''
      <tr>
        <td style="padding: 12px; border-bottom: 1px solid #e5e7eb;">${_escape(item.name)}</td>
        <td style="padding: 12px; text-align: center; border-bottom: 1px solid #e5e7eb;">${item.quantity}</td>
        <td style="padding: 12px; text-align: right; border-bottom: 1px solid #e5e7eb;">$currencySymbol${numberFormat.format(item.price)}</td>
        <td style="padding: 12px; text-align: right; border-bottom: 1px solid #e5e7eb;">$currencySymbol${numberFormat.format(item.total)}</td>
      </tr>
      ''';
    }).join('\n');

    DateTime? invoiceDate;
    if (invoice.invoiceDate != null) {
      try {
        invoiceDate = DateTime.parse(invoice.invoiceDate!);
      } catch (_) {}
    }

    DateTime? dueDate;
    if (invoice.dueDate != null) {
      try {
        dueDate = DateTime.parse(invoice.dueDate!);
      } catch (_) {}
    }

    return _buildHtml(
      invoiceNumber: invoice.invoiceNumber,
      invoiceDateStr: invoiceDate != null ? dateFormat.format(invoiceDate) : invoice.invoiceDate ?? '',
      dueDateStr: dueDate != null ? dateFormat.format(dueDate) : invoice.dueDate,
      customerName: invoice.customerName ?? 'Customer',
      customerEmail: invoice.customerEmail,
      customerPhone: null,
      itemsHtml: itemsHtml,
      subTotal: invoice.subTotal,
      tax: invoice.tax,
      total: invoice.total,
      notes: invoice.notes,
      currencySymbol: currencySymbol,
      numberFormat: numberFormat,
      companyName: null,
      companyAddress: null,
      status: invoice.status,
      paidStatus: invoice.paidStatus,
    );
  }

  /// Generate preview from form data (for new invoices)
  static String generate({
    required String invoiceNumber,
    required DateTime invoiceDate,
    DateTime? dueDate,
    Customer? customer,
    required List<LineItem> lineItems,
    required double subTotal,
    required double tax,
    required double total,
    String? notes,
    String currencySymbol = '\$',
    String? companyName,
    String? companyAddress,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final numberFormat = NumberFormat('#,##0.00');

    final itemsHtml = lineItems.where((item) => item.name.isNotEmpty).map((item) {
      return '''
      <tr>
        <td style="padding: 12px; border-bottom: 1px solid #e5e7eb;">${_escape(item.name)}</td>
        <td style="padding: 12px; text-align: center; border-bottom: 1px solid #e5e7eb;">${item.quantity}</td>
        <td style="padding: 12px; text-align: right; border-bottom: 1px solid #e5e7eb;">$currencySymbol${numberFormat.format(item.price)}</td>
        <td style="padding: 12px; text-align: right; border-bottom: 1px solid #e5e7eb;">$currencySymbol${numberFormat.format(item.total)}</td>
      </tr>
      ''';
    }).join('\n');

    return _buildHtml(
      invoiceNumber: invoiceNumber,
      invoiceDateStr: dateFormat.format(invoiceDate),
      dueDateStr: dueDate != null ? dateFormat.format(dueDate) : null,
      customerName: customer?.name ?? 'Customer',
      customerEmail: customer?.email,
      customerPhone: customer?.phone,
      itemsHtml: itemsHtml,
      subTotal: subTotal,
      tax: tax,
      total: total,
      notes: notes,
      currencySymbol: currencySymbol,
      numberFormat: numberFormat,
      companyName: companyName,
      companyAddress: companyAddress,
    );
  }

  static String _buildHtml({
    required String invoiceNumber,
    required String invoiceDateStr,
    String? dueDateStr,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    required String itemsHtml,
    required double subTotal,
    required double tax,
    required double total,
    String? notes,
    required String currencySymbol,
    required NumberFormat numberFormat,
    String? companyName,
    String? companyAddress,
    String? status,
    String? paidStatus,
  }) {
    String statusBadge = '';
    if (status != null || paidStatus != null) {
      final badges = <String>[];
      if (status != null && status != 'DRAFT') {
        final color = _getStatusColor(status);
        badges.add('<span style="background: $color; color: white; padding: 4px 12px; border-radius: 4px; font-size: 12px; font-weight: 600;">$status</span>');
      }
      if (paidStatus != null) {
        final color = _getPaidStatusColor(paidStatus);
        badges.add('<span style="background: $color; color: white; padding: 4px 12px; border-radius: 4px; font-size: 12px; font-weight: 600;">$paidStatus</span>');
      }
      if (badges.isNotEmpty) {
        statusBadge = '<div style="display: flex; gap: 8px; margin-top: 8px;">${badges.join('')}</div>';
      }
    }

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Invoice $invoiceNumber</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      font-size: 14px;
      line-height: 1.5;
      color: #1f2937;
      background: #fff;
      padding: 24px;
    }
    .invoice-container {
      max-width: 800px;
      margin: 0 auto;
      background: #fff;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 32px;
      padding-bottom: 24px;
      border-bottom: 2px solid #1565C0;
    }
    .company-info h1 {
      font-size: 24px;
      color: #1565C0;
      margin-bottom: 8px;
    }
    .company-info p {
      color: #6b7280;
      font-size: 13px;
    }
    .invoice-badge {
      background: #1565C0;
      color: white;
      padding: 8px 16px;
      border-radius: 4px;
      font-weight: 600;
      font-size: 18px;
    }
    .info-section {
      display: flex;
      justify-content: space-between;
      margin-bottom: 32px;
    }
    .info-block h3 {
      font-size: 12px;
      text-transform: uppercase;
      color: #6b7280;
      margin-bottom: 8px;
      letter-spacing: 0.05em;
    }
    .info-block p {
      margin-bottom: 4px;
    }
    .info-block .value {
      font-weight: 500;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 24px;
    }
    thead {
      background: #f3f4f6;
    }
    th {
      padding: 12px;
      text-align: left;
      font-weight: 600;
      font-size: 12px;
      text-transform: uppercase;
      color: #6b7280;
      letter-spacing: 0.05em;
    }
    th:nth-child(2), th:nth-child(3), th:nth-child(4) {
      text-align: right;
    }
    th:nth-child(2) { text-align: center; }
    .totals {
      margin-left: auto;
      width: 280px;
    }
    .totals-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #e5e7eb;
    }
    .totals-row.total {
      font-weight: 700;
      font-size: 16px;
      border-bottom: none;
      border-top: 2px solid #1f2937;
      padding-top: 12px;
      margin-top: 8px;
    }
    .notes {
      margin-top: 32px;
      padding: 16px;
      background: #f9fafb;
      border-radius: 8px;
    }
    .notes h3 {
      font-size: 12px;
      text-transform: uppercase;
      color: #6b7280;
      margin-bottom: 8px;
    }
    .notes p {
      color: #4b5563;
      white-space: pre-wrap;
    }
    .footer {
      margin-top: 48px;
      text-align: center;
      color: #9ca3af;
      font-size: 12px;
    }
  </style>
</head>
<body>
  <div class="invoice-container">
    <div class="header">
      <div class="company-info">
        <h1>${_escape(companyName ?? 'Your Company')}</h1>
        ${companyAddress != null ? '<p>${_escape(companyAddress)}</p>' : ''}
      </div>
      <div class="invoice-badge">INVOICE</div>
    </div>

    <div class="info-section">
      <div class="info-block">
        <h3>Bill To</h3>
        <p class="value">${_escape(customerName)}</p>
        ${customerEmail != null ? '<p>${_escape(customerEmail)}</p>' : ''}
        ${customerPhone != null ? '<p>${_escape(customerPhone)}</p>' : ''}
      </div>
      <div class="info-block" style="text-align: right;">
        <h3>Invoice Details</h3>
        <p><span style="color: #6b7280;">Invoice #:</span> <span class="value">$invoiceNumber</span></p>
        <p><span style="color: #6b7280;">Date:</span> <span class="value">$invoiceDateStr</span></p>
        ${dueDateStr != null ? '<p><span style="color: #6b7280;">Due Date:</span> <span class="value">$dueDateStr</span></p>' : ''}
        $statusBadge
      </div>
    </div>

    <table>
      <thead>
        <tr>
          <th style="text-align: left;">Item</th>
          <th style="text-align: center;">Qty</th>
          <th style="text-align: right;">Price</th>
          <th style="text-align: right;">Total</th>
        </tr>
      </thead>
      <tbody>
        $itemsHtml
      </tbody>
    </table>

    <div class="totals">
      <div class="totals-row">
        <span>Subtotal</span>
        <span>$currencySymbol${numberFormat.format(subTotal)}</span>
      </div>
      <div class="totals-row">
        <span>Tax</span>
        <span>$currencySymbol${numberFormat.format(tax)}</span>
      </div>
      <div class="totals-row total">
        <span>Total</span>
        <span>$currencySymbol${numberFormat.format(total)}</span>
      </div>
    </div>

    ${notes != null && notes.isNotEmpty ? '''
    <div class="notes">
      <h3>Notes</h3>
      <p>${_escape(notes)}</p>
    </div>
    ''' : ''}

    <div class="footer">
      <p>Thank you for your business!</p>
    </div>
  </div>
</body>
</html>
''';
  }

  static String _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SENT':
        return '#3B82F6';
      case 'VIEWED':
        return '#8B5CF6';
      case 'COMPLETED':
        return '#10B981';
      case 'DUE':
        return '#F59E0B';
      default:
        return '#6B7280';
    }
  }

  static String _getPaidStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return '#10B981';
      case 'PARTIALLY_PAID':
        return '#F59E0B';
      case 'UNPAID':
        return '#EF4444';
      default:
        return '#6B7280';
    }
  }

  static String _escape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
