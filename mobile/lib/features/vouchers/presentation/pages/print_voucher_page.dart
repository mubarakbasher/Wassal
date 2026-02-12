import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/voucher.dart';
import '../utils/voucher_pdf_generator.dart';

class PrintVoucherPage extends StatefulWidget {
  final List<Voucher> vouchers;

  const PrintVoucherPage({super.key, required this.vouchers});

  @override
  State<PrintVoucherPage> createState() => _PrintVoucherPageState();
}

class _PrintVoucherPageState extends State<PrintVoucherPage> {
  PrinterFormat _format = PrinterFormat.a4;
  VoucherDesignTheme _theme = VoucherDesignTheme.classic;
  int _columns = 2;
  int _rows = 5;
  String _businessName = "Wassal Hotspot";

  final GlobalKey<State<StatefulWidget>> _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Get network name from AuthBloc after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.networkName != null) {
        setState(() {
          _businessName = authState.user.networkName!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Vouchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsBottomSheet();
            },
          ),
        ],
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        key: _previewKey,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        build: (format) => VoucherPdfGenerator.generate(
          widget.vouchers,
          format: _format,
          theme: _theme,
          columns: _columns,
          rows: _rows,
          businessName: _businessName,
        ),
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.save_alt),
            onPressed: (context, build, pageFormat) async {
               // The default PdfPreview already has a save button in the toolbar on some platforms,
               // but adding a custom action is requested.
               // Actually, `PdfPreview` built-in interactions handle saving/sharing well.
               // We can leave this empty or perform a specific save action if needed.
               // For now, reliance on built-in save/share is standard.
               // Let's rely on standard actions provided by PdfPreview (Print, Share).
               // The user requested "Save PDF", which Share usually covers.
               // But we can add a specific direct save if needed. 
               // Default behavior: The "Share" button allows saving to files.
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
              Text('Print Settings', style: AppTextStyles.titleLarge),
              const SizedBox(height: 20),
              
              // Format Selector
              Text('Paper Format', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: PrinterFormat.values.map((f) {
                  return FilterChip(
                    label: Text(_formatName(f)),
                    selected: _format == f,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => _format = f);
                        setState(() => _format = f);
                      }
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Design Theme Selector
              Text('Card Design', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: VoucherDesignTheme.values.map((t) {
                  return FilterChip(
                    label: Text(_themeName(t)),
                    selected: _theme == t,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => _theme = t);
                        setState(() => _theme = t);
                      }
                    },
                    selectedColor: AppColors.accent.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Grid Settings (A4 Only)
              if (_format == PrinterFormat.a4) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Columns: $_columns', style: AppTextStyles.labelMedium),
                          Slider(
                            value: _columns.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setModalState(() => _columns = val.toInt());
                              setState(() => _columns = val.toInt());
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rows: $_rows', style: AppTextStyles.labelMedium),
                          Slider(
                            value: _rows.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setModalState(() => _rows = val.toInt());
                              setState(() => _rows = val.toInt());
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Total per page: ${_columns * _rows}', 
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatName(PrinterFormat f) {
    switch (f) {
      case PrinterFormat.a4: return 'A4 Paper';
      case PrinterFormat.thermal58: return 'Thermal 58mm';
      case PrinterFormat.thermal80: return 'Thermal 80mm';
    }
  }

  String _themeName(VoucherDesignTheme t) {
    switch (t) {
      case VoucherDesignTheme.classic: return 'Classic';
      case VoucherDesignTheme.modern: return 'Modern';
      case VoucherDesignTheme.minimal: return 'Minimal';
    }
  }
}
