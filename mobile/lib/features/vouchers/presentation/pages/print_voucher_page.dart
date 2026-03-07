import 'package:flutter/material.dart';
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
        title: Text(AppLocalizations.of(context)!.printVouchers),
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
        key: ValueKey('$_format-$_theme-$_columns-$_businessName'),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        build: (format) => VoucherPdfGenerator.generate(
          widget.vouchers,
          format: _format,
          theme: _theme,
          columns: _columns,
          businessName: _businessName,
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
