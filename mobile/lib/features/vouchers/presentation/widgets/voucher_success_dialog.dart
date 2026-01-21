import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/voucher.dart';

class VoucherSuccessDialog extends StatelessWidget {
  final List<Voucher> vouchers;
  final VoidCallback onDismiss;

  const VoucherSuccessDialog({
    super.key,
    required this.vouchers,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
             Text(
              vouchers.length > 1 
                  ? "${vouchers.length} Vouchers Generated!" 
                  : "Voucher Generated!",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Voucher List or Single Card
            Flexible(
              child: SingleChildScrollView(
                child: vouchers.length == 1 
                  ? _buildSingleVoucher(vouchers.first)
                  : _buildVoucherList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                        Clipboard.setData(ClipboardData(text: _getShareText()));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy All"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                         Share.share(_getShareText());
                    },
                    icon: const Icon(Icons.print),
                    label: const Text("Print / Share"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 12),
             TextButton(
               onPressed: onDismiss,
               child: const Text("Close"),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildSingleVoucher(Voucher voucher) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildRow("Username", voucher.username),
          const Divider(),
          _buildRow("Password", voucher.password),
          const Divider(),
          _buildRow("Plan", voucher.planName),
          const Divider(),
          _buildRow("Price", "\$${voucher.price}"),
        ],
      ),
    );
  }

  Widget _buildVoucherList() {
    return Column(
      children: vouchers.map((v) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
             _buildRow("Username", v.username),
             _buildRow("Password", v.password),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getShareText() {
    final buffer = StringBuffer();
    buffer.writeln("WASSAL HOTSPOT VOUCHERS");
    buffer.writeln("----------------------");
    
    for (var v in vouchers) {
      buffer.writeln("Username: ${v.username}");
      buffer.writeln("Password: ${v.password}");
      if(vouchers.length == 1) {
         buffer.writeln("Plan:     ${v.planName}");
         buffer.writeln("Price:    \$${v.price}");
      }
      buffer.writeln("- - - - - - - - - - -");
    }
    
    buffer.writeln("Login at: http://mikrotik");
    return buffer.toString();
  }
}
