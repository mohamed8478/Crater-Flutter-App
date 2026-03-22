import 'package:flutter/material.dart';

class AppColors {
  // Primary brand purple (matches web #5851D8 → #8A85E4)
  static const Color primary50 = Color(0xFFF7F6FD);
  static const Color primary100 = Color(0xFFEEEEFB);
  static const Color primary200 = Color(0xFFD5D4F5);
  static const Color primary300 = Color(0xFFBCB9EF);
  static const Color primary400 = Color(0xFF8A85E4);
  static const Color primary500 = Color(0xFF5851D8); // main brand
  static const Color primary600 = Color(0xFF4F49C2);
  static const Color primary700 = Color(0xFF353182);
  static const Color primary800 = Color(0xFF282461);
  static const Color primary900 = Color(0xFF1A1841);

  // Gradient (header background)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary500, primary400],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Slate grays (Tailwind slate)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  // Invoice status badge colors
  static const Color statusDraft = Color(0xFF94A3B8);
  static const Color statusSent = Color(0xFF3B82F6);
  static const Color statusViewed = Color(0xFF8B5CF6);
  static const Color statusDue = Color(0xFFF59E0B);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusPaid = Color(0xFF10B981);
  static const Color statusUnpaid = Color(0xFFEF4444);
  static const Color statusPartiallyPaid = Color(0xFFF59E0B);
  static const Color statusOverdue = Color(0xFFEF4444);
}
