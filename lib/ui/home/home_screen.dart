import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/dependencies/injection.dart';
import '../invoice/scanner_screen.dart';
import '../shared/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobileView(),
      tablet: const _TabletView(),
    );
  }
}

// ── Shared Content Helper ────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  final bool isTablet;
  const _DashboardContent({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final user = Injection.authViewModel.currentUser;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          backgroundColor: const Color(0xFF0F1117),
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.account_balance_rounded, color: Color(0xFF6C63FF)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => Injection.authViewModel.logout(),
                icon: const Icon(Icons.logout_rounded, color: Color(0xFF8B8FA8)),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 48.0 : 24.0,
            vertical: 12,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('Welcome,', style: GoogleFonts.inter(color: const Color(0xFF8B8FA8), fontSize: 14)),
              Text(
                user?.name ?? 'Admin User',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              // ── Responsive Layout Logic ──────────────────
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _ScannerActionCard(onTap: () => _openScanner(context))),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _QuickStatsCard()),
                  ],
                )
              else
                _ScannerActionCard(onTap: () => _openScanner(context)),
              
              const SizedBox(height: 48),
              
              Text('Management', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 4 : 2, // 4 columns on tablet
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.3,
                children: [
                  _QuickActionTile(label: 'Invoices', icon: Icons.receipt_long_rounded, color: const Color(0xFF6C63FF)),
                  _QuickActionTile(label: 'Customers', icon: Icons.people_alt_rounded, color: const Color(0xFF3B82F6)),
                  _QuickActionTile(label: 'Estimates', icon: Icons.description_rounded, color: const Color(0xFF10B981)),
                  _QuickActionTile(label: 'Settings', icon: Icons.settings_rounded, color: const Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
  }
}

// ── Device Specific View Wrappers ────────────────────────────
class _MobileView extends StatelessWidget {
  const _MobileView();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF0F1117), body: _DashboardContent());
}

class _TabletView extends StatelessWidget {
  const _TabletView();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF0F1117), body: _DashboardContent(isTablet: true));
}

// ── Components ──────────────────────────────────────────────
class _ScannerActionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ScannerActionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 32),
          Text('Scan New Invoice', style: GoogleFonts.inter(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Extract data from physical receipts automatically.', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, foregroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Start Scanning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF2A2D3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Sales', style: GoogleFonts.inter(color: const Color(0xFF8B8FA8), fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('\$12,450.00', style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2A2D3E)),
          const SizedBox(height: 24),
          _StatRow(label: 'Pending Invoices', value: '14', color: const Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          _StatRow(label: 'Unpaid Estimates', value: '8', color: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.inter(color: const Color(0xFF8B8FA8), fontSize: 13)),
          ],
        ),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickActionTile({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2D3E)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
