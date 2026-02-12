import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/voucher.dart';
import '../utils/voucher_pdf_generator.dart';

class VoucherSuccessDialog extends StatefulWidget {
  final List<Voucher> vouchers;
  final VoidCallback onDismiss;
  final String? networkName;

  const VoucherSuccessDialog({
    super.key,
    required this.vouchers,
    required this.onDismiss,
    this.networkName,
  });

  @override
  State<VoucherSuccessDialog> createState() => _VoucherSuccessDialogState();
}

class _VoucherSuccessDialogState extends State<VoucherSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSuccessIcon(),
              const SizedBox(height: 20),
              Text(
                widget.vouchers.length > 1
                    ? "${widget.vouchers.length} Vouchers Generated!"
                    : "Voucher Generated!",
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your vouchers are ready to use',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Voucher Preview
              Flexible(
                child: SingleChildScrollView(
                  child: widget.vouchers.length == 1
                      ? _buildSingleVoucher(widget.vouchers.first)
                      : _buildVoucherList(),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onPressed: _copyToClipboard,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onPressed: _shareVouchers,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPrintButton(),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onDismiss,
                child: Text(
                  'Done',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  Widget _buildSingleVoucher(Voucher voucher) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.networkName ?? 'WASSAL',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '\$${voucher.price.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'USERNAME',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 4),
                Text(
                  voucher.username,
                  style: AppTextStyles.voucherCode.copyWith(color: Colors.white),
                ),
                if (voucher.password.isNotEmpty && voucher.password != voucher.username) ...[
                  const SizedBox(height: 12),
                  Text(
                    'PASSWORD',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voucher.password,
                    style: AppTextStyles.voucherCode.copyWith(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            voucher.planName,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherList() {
    return Column(
      children: widget.vouchers.take(5).map((v) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.username,
                    style: AppTextStyles.voucherCode.copyWith(fontSize: 14),
                  ),
                  if (v.password.isNotEmpty && v.password != v.username)
                    Text(
                      'Pass: ${v.password}',
                      style: AppTextStyles.bodySmall,
                    ),
                ],
              ),
            ),
            Text(
              '\$${v.price.toStringAsFixed(2)}',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPrintButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showPrintOptions();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.print_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Print Vouchers', style: AppTextStyles.button),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _getShareText()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareVouchers() {
    Share.share(_getShareText());
  }

  void _showPrintOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Print Format', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Choose the paper size for your printer',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            _buildPrintOption(
              'A4 Paper',
              'Standard printer, 10 vouchers per page',
              Icons.description_outlined,
              PrinterFormat.a4,
            ),
            _buildPrintOption(
              '80mm Thermal',
              'Receipt printer, detailed layout',
              Icons.receipt_long_outlined,
              PrinterFormat.thermal80,
            ),
            _buildPrintOption(
              '58mm Thermal',
              'Small receipt printer, compact',
              Icons.receipt_outlined,
              PrinterFormat.thermal58,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintOption(
    String title,
    String subtitle,
    IconData icon,
    PrinterFormat format,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      onTap: () {
        Navigator.pop(context);
        _printWithFormat(format);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _printWithFormat(PrinterFormat format) async {
    try {
      final pdfBytes = await VoucherPdfGenerator.generate(
        widget.vouchers,
        format: format,
        businessName: widget.networkName,
      );
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'vouchers_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _getShareText() {
    final buffer = StringBuffer();
    final networkDisplayName = widget.networkName ?? 'WASSAL HOTSPOT';
    buffer.writeln('═══════════════════════');
    buffer.writeln('    $networkDisplayName');
    buffer.writeln('═══════════════════════');
    buffer.writeln();

    for (var v in widget.vouchers) {
      buffer.writeln('Username: ${v.username}');
      if (v.password.isNotEmpty && v.password != v.username) {
        buffer.writeln('Password: ${v.password}');
      }
      if (widget.vouchers.length == 1) {
        buffer.writeln('Plan: ${v.planName}');
        buffer.writeln('Price: \$${v.price}');
      }
      buffer.writeln('───────────────────────');
    }

    buffer.writeln();
    buffer.writeln('Connect to WiFi and login at:');
    buffer.writeln('http://mikrotik');
    buffer.writeln();
    buffer.writeln('Thank you! 🙏');
    return buffer.toString();
  }
}
