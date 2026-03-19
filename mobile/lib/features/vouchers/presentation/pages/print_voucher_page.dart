import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
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
  String _businessName = "Wassal Hotspot";
  String? _pdfError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.networkName != null) {
        setState(() {
          _businessName = authState.user.networkName!;
        });
      }
    });
  }

  Future<Uint8List> _buildPdfSafely(PdfPageFormat format) async {
    try {
      return await VoucherPdfGenerator.generate(
        widget.vouchers,
        format: _format,
        theme: _theme,
        columns: _columns,
        businessName: _businessName,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _pdfError = e.toString());
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.printVouchers ?? 'Print Vouchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsBottomSheet();
            },
          ),
        ],
      ),
      body: _pdfError != null
          ? _buildErrorState()
          : PdfPreview(
              maxPageWidth: 700,
              key: ValueKey('$_format-$_theme-$_columns-$_businessName'),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              build: _buildPdfSafely,
              onError: (context, error) => _buildPdfErrorWidget(error),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to generate PDF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _pdfError ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _pdfError = null),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfErrorWidget(dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('PDF generation failed', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              Text(AppLocalizations.of(context)!.printSettings, style: AppTextStyles.titleLarge),
              const SizedBox(height: 20),
              
              // Format Selector
              Text(AppLocalizations.of(context)!.paperFormat, style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: PrinterFormat.values.map((f) {
                  return FilterChip(
                    label: Text(_formatName(context, f)),
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
              Text(AppLocalizations.of(context)!.cardDesign, style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: VoucherDesignTheme.values.map((t) {
                  return FilterChip(
                    label: Text(_themeName(context, t)),
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
                Text(AppLocalizations.of(context)!.columns(_columns), style: AppTextStyles.labelMedium),
                Slider(
                  value: _columns.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setModalState(() => _columns = val.toInt());
                    setState(() => _columns = val.toInt());
                  },
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
                  child: Text(AppLocalizations.of(context)!.applyChanges),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatName(BuildContext context, PrinterFormat f) {
    switch (f) {
      case PrinterFormat.a4: return AppLocalizations.of(context)!.a4Paper;
      case PrinterFormat.thermal58: return AppLocalizations.of(context)!.thermal58mm;
      case PrinterFormat.thermal80: return AppLocalizations.of(context)!.thermal80mm;
    }
  }

  String _themeName(BuildContext context, VoucherDesignTheme t) {
    switch (t) {
      case VoucherDesignTheme.classic: return AppLocalizations.of(context)!.classic;
      case VoucherDesignTheme.modern: return AppLocalizations.of(context)!.modern;
      case VoucherDesignTheme.minimal: return AppLocalizations.of(context)!.minimal;
    }
  }
}
