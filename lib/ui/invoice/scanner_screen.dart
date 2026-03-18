import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scanner_view_model.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _viewModel = ScannerViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showResult(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1D2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _ScannerResultPanel(viewModel: _viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: Text('Invoice Scanner', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.status == ScannerStatus.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _showResult(context));
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Visual Guide Icon ───────────────────────────
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D2E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.document_scanner_rounded, size: 48, color: Color(0xFF6C63FF)),
                  ),
                  const SizedBox(height: 32),
                  
                  // ── Instructions ────────────────────────────────
                  Text(
                    'Scan Physical Invoice',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Capture a photo of your receipt to extract data automatically.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8B8FA8)),
                  ),
                  const SizedBox(height: 48),

                  // ── Main Action ─────────────────────────────────
                  _ScannerButton(
                    label: 'Use Camera',
                    icon: Icons.camera_alt_rounded,
                    primary: true,
                    isLoading: _viewModel.status == ScannerStatus.scanning || _viewModel.status == ScannerStatus.picking,
                    onTap: _viewModel.scanFromCamera,
                  ),
                  const SizedBox(height: 16),
                  _ScannerButton(
                    label: 'Choose from Gallery',
                    icon: Icons.photo_library_rounded,
                    primary: false,
                    onTap: _viewModel.scanFromGallery,
                  ),
                  
                  if (_viewModel.status == ScannerStatus.error) ...[
                    const SizedBox(height: 24),
                    Text(
                      _viewModel.errorMessage ?? 'Something went wrong.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFE11D48), fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScannerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final bool isLoading;
  final VoidCallback onTap;

  const _ScannerButton({
    required this.label,
    required this.icon,
    this.primary = true,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
          : Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? const Color(0xFF6C63FF) : const Color(0xFF1A1D2E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: primary ? Colors.transparent : const Color(0xFF2A2D3E)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _ScannerResultPanel extends StatelessWidget {
  final ScannerViewModel viewModel;
  const _ScannerResultPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final data = viewModel.scannedData;
    final bool hasDataGap = viewModel.errorMessage != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Extracted Data', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF8B8FA8))),
            ],
          ),
          const SizedBox(height: 8),
          
          if (hasDataGap)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: const Color(0xFFE11D48).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 18),
                  const SizedBox(width: 12),
                  Expanded(child: Text(viewModel.errorMessage!, style: const TextStyle(color: Color(0xFFE11D48), fontSize: 12))),
                ],
              ),
            ),

          _ResultField(label: 'Total Amount', value: data?.totalAmount?.toStringAsFixed(2), icon: Icons.attach_money_rounded),
          _ResultField(label: 'Date', value: data?.date?.toIso8601String().split('T').first, icon: Icons.calendar_today_rounded),
          _ResultField(label: 'Invoice Number', value: data?.invoiceNumber, icon: Icons.tag_rounded),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Future: Navigate to Create Invoice Form with this data
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice data pre-filled!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Confirm & Create'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;

  const _ResultField({required this.label, this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFF8B8FA8), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1117),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: value == null ? const Color(0xFFE11D48).withOpacity(0.3) : const Color(0xFF2A2D3E)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: value == null ? const Color(0xFFE11D48) : const Color(0xFF6C63FF)),
                const SizedBox(width: 16),
                Text(
                  value ?? 'Not found',
                  style: TextStyle(
                    color: value == null ? const Color(0xFFE11D48) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
