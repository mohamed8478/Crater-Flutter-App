import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.fromInvoiceStatus(String status) {
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
      case 'VIEWED':
        bg = const Color(0xFFEDE9FE);
        text = const Color(0xFF7C3AED);
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
    return StatusBadge(label: status.toUpperCase(), backgroundColor: bg, textColor: text);
  }

  factory StatusBadge.fromPaidStatus(String paidStatus) {
    Color bg;
    Color text;
    switch (paidStatus.toUpperCase()) {
      case 'PAID':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF059669);
        break;
      case 'PARTIALLY_PAID':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        break;
      case 'UNPAID':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        break;
      default:
        bg = AppColors.slate100;
        text = AppColors.slate600;
    }
    final display = paidStatus.replaceAll('_', ' ').toUpperCase();
    return StatusBadge(label: display, backgroundColor: bg, textColor: text);
  }

  factory StatusBadge.fromEstimateStatus(String status) {
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
      case 'VIEWED':
        bg = const Color(0xFFEDE9FE);
        text = const Color(0xFF7C3AED);
        break;
      case 'ACCEPTED':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF059669);
        break;
      case 'REJECTED':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        break;
      case 'EXPIRED':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        break;
      default:
        bg = AppColors.slate100;
        text = AppColors.slate600;
    }
    return StatusBadge(label: status.toUpperCase(), backgroundColor: bg, textColor: text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
