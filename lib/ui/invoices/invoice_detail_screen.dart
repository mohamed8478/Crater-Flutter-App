import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme/app_colors.dart';
import '../../data/models/invoice.dart';
import '../../data/services/invoice_api_service.dart';
import '../../routing/app_router.dart';
import '../widgets/status_badge.dart';
import 'models/invoice_preview_args.dart';
import 'invoice_preview_generator.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceApiService invoiceService;
  final String token;
  final int? companyId;
  final int? invoiceId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceService,
    required this.token,
    this.companyId,
    this.invoiceId,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Invoice? _invoice;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.invoiceId == null) {
      setState(() {
        _error = 'Missing invoice id';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final invoice = await widget.invoiceService.getInvoice(
        widget.token,
        widget.invoiceId!,
        companyId: widget.companyId,
      );
      setState(() => _invoice = invoice);
    } catch (e) {
      setState(() => _error = 'Failed to load invoice: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openPreview() async {
    if (_invoice == null) return;
    try {
      // Generate preview locally instead of API call
      final html = InvoicePreviewGenerator.generateFromInvoice(_invoice!);
      if (!mounted) return;
      context.push(
        AppRoutes.invoicePreview,
        extra: InvoicePreviewArgs(html: html, title: _invoice!.invoiceNumber),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preview unavailable: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_invoice?.invoiceNumber ?? 'Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: _invoice == null ? null : _openPreview,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildTotalsCard(),
                      const SizedBox(height: 16),
                      if ((_invoice?.notes ?? '').isNotEmpty) _buildNotes(),
                      if (_invoice!.scanAttachments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildAttachments(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final invoice = _invoice!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.invoiceNumber, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (invoice.customerName != null)
              Text(invoice.customerName!, style: const TextStyle(color: AppColors.slate500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge.fromInvoiceStatus(invoice.status),
                StatusBadge.fromPaidStatus(invoice.paidStatus),
                if (invoice.overdue)
                  const StatusBadge(
                    label: 'OVERDUE',
                    backgroundColor: Color(0xFFFEE2E2),
                    textColor: Color(0xFFDC2626),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('Invoice date', invoice.invoiceDate ?? '—'),
            _infoRow('Due date', invoice.dueDate ?? '—'),
            _infoRow('Status', invoice.status),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    final invoice = _invoice!;
    final currency = invoice.currencySymbol ?? '\$';
    final formatter = NumberFormat('#,##0.00');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _totalRow('Subtotal', '$currency${formatter.format(invoice.subTotal)}'),
            _totalRow('Tax', '$currency${formatter.format(invoice.tax)}'),
            _totalRow('Discount', '$currency${formatter.format(invoice.discount)}'),
            const Divider(),
            _totalRow('Total', '$currency${formatter.format(invoice.total)}', bold: true),
            _totalRow('Due', '$currency${formatter.format(invoice.dueAmount)}', bold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_invoice!.notes ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scanned attachments', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._invoice!.scanAttachments.map((attachment) {
              final isPdf = attachment.mimeType.contains('pdf') ||
                  attachment.fileName.toLowerCase().endsWith('.pdf');
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                  color: isPdf ? AppColors.danger : AppColors.primary500,
                ),
                title: Text(attachment.fileName),
                subtitle: Text('${(attachment.size / 1024).toStringAsFixed(1)} KB • ${attachment.mimeType}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // On web for PDFs, prefer direct download
                    if (kIsWeb && isPdf)
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'Download',
                        onPressed: () async {
                          final url = Uri.parse(attachment.url);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Open',
                        onPressed: () {
                          context.push(
                            AppRoutes.invoicePreview,
                            extra: InvoicePreviewArgs(url: attachment.url, title: attachment.fileName),
                          );
                        },
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.slate400))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
