import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/voucher.dart';

// App theme colors for PDF
class PdfAppColors {
  static const PdfColor primary = PdfColor.fromInt(0xFF1E3A5F); // Deep Navy
  static const PdfColor primaryLight = PdfColor.fromInt(0xFF2E5A8B); // Lighter Navy
  static const PdfColor accent = PdfColor.fromInt(0xFF00D4FF); // Electric Cyan
  static const PdfColor textDark = PdfColor.fromInt(0xFF1E293B); // Dark Slate
  static const PdfColor textLight = PdfColor.fromInt(0xFF64748B); // Light Slate
}

enum PrinterFormat {
  a4,       // Standard A4 paper
  thermal58, // 58mm thermal printer
  thermal80, // 80mm thermal printer
}

enum VoucherDesignTheme {
  classic,
  modern,
  minimal,
}

class VoucherPdfGenerator {
  /// Generate PDF with customizable layout and design
  static Future<Uint8List> generate(
    List<Voucher> vouchers, {
    PrinterFormat format = PrinterFormat.a4,
    VoucherDesignTheme theme = VoucherDesignTheme.classic,
    int columns = 2,
    int rows = 5,
    String? businessName,
    String? loginUrl,
  }) async {
    switch (format) {
      case PrinterFormat.a4:
        return _generateA4(
          vouchers, 
          columns: columns, 
          rows: rows, 
          theme: theme,
          businessName: businessName, 
          loginUrl: loginUrl
        );
      case PrinterFormat.thermal58:
        return _generateThermal(
          vouchers, 
          widthMm: 58.0, 
          theme: theme,
          businessName: businessName, 
          loginUrl: loginUrl
        );
      case PrinterFormat.thermal80:
        return _generateThermal(
          vouchers, 
          widthMm: 80.0, 
          theme: theme,
          businessName: businessName, 
          loginUrl: loginUrl
        );
    }
  }

  /// Standard A4 layout with dynamic grid
  static Future<Uint8List> _generateA4(
    List<Voucher> vouchers, {
    required int columns,
    required int rows,
    required VoucherDesignTheme theme,
    String? businessName,
    String? loginUrl,
  }) async {
    final doc = pw.Document();
    
    // Load fonts
    final fontTitle = await PdfGoogleFonts.nunitoBold();
    final fontBody = await PdfGoogleFonts.nunitoRegular();
    final fontMono = await PdfGoogleFonts.jetBrainsMonoBold();

    // Calculate dimensions
    const pageFormat = PdfPageFormat.a4;
    const margin = 15.0; // mm
    const spacing = 10.0; // mm
    
    // Available width/height for vouchers in points
    final contentWidth = pageFormat.availableWidth - (margin * PdfPageFormat.mm * 2);
    final contentHeight = pageFormat.availableHeight - (margin * PdfPageFormat.mm * 2);
    
    // Calculate voucher card size
    // Width: (Total Width - ((cols-1) * spacing)) / cols
    final cardWidth = (contentWidth - ((columns - 1) * spacing * PdfPageFormat.mm)) / columns;
    
    // Height: (Total Height - ((rows-1) * spacing)) / rows
    final cardHeight = (contentHeight - ((rows - 1) * spacing * PdfPageFormat.mm)) / rows;

    final vouchersPerPage = columns * rows;
    
    // Split vouchers into chunks (pages)
    for (var i = 0; i < vouchers.length; i += vouchersPerPage) {
      final end = (i + vouchersPerPage < vouchers.length) ? i + vouchersPerPage : vouchers.length;
      final pageVouchers = vouchers.sublist(i, end);

      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(margin * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Wrap(
              spacing: spacing * PdfPageFormat.mm,
              runSpacing: spacing * PdfPageFormat.mm,
              children: pageVouchers.map((voucher) {
                return pw.SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _buildCard(
                    voucher, 
                    theme, 
                    fontTitle, 
                    fontBody, 
                    fontMono,
                    businessName: businessName,
                    loginUrl: loginUrl,
                  ),
                );
              }).toList(),
            );
          },
        ),
      );
    }

    return doc.save();
  }

  /// Generic Thermal Printer Layout
  static Future<Uint8List> _generateThermal(
    List<Voucher> vouchers, {
    required double widthMm,
    required VoucherDesignTheme theme,
    String? businessName,
    String? loginUrl,
  }) async {
    final doc = pw.Document();
    final fontTitle = await PdfGoogleFonts.nunitoBold();
    final fontBody = await PdfGoogleFonts.nunitoRegular();
    final fontMono = await PdfGoogleFonts.jetBrainsMonoBold();

    final pageWidth = widthMm * PdfPageFormat.mm;
    
    // For thermal, we typically print one long roll or paginate per voucher.
    // Here we paginate per voucher for cleaner cuts.
    for (final voucher in vouchers) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, double.infinity),
          margin: const pw.EdgeInsets.symmetric(horizontal: 4 * PdfPageFormat.mm, vertical: 4 * PdfPageFormat.mm),
          build: (context) {
            return _buildThermalCard(
              voucher, 
              widthMm, 
              theme,
              fontTitle, 
              fontBody, 
              fontMono,
              businessName: businessName,
              loginUrl: loginUrl,
            );
          },
        ),
      );
    }

    return doc.save();
  }

  // --- Card Builders ---

  static pw.Widget _buildCard(
    Voucher voucher,
    VoucherDesignTheme theme,
    pw.Font fontTitle,
    pw.Font fontBody,
    pw.Font fontMono, {
    String? businessName,
    String? loginUrl,
  }) {
    switch (theme) {
      case VoucherDesignTheme.modern:
        return _buildModernCard(voucher, fontTitle, fontBody, fontMono, businessName, loginUrl);
      case VoucherDesignTheme.minimal:
        return _buildMinimalCard(voucher, fontTitle, fontBody, fontMono, businessName, loginUrl);
      case VoucherDesignTheme.classic:
      default:
        return _buildClassicCard(voucher, fontTitle, fontBody, fontMono, businessName, loginUrl);
    }
  }

  // 1. Classic Design (Bordered, functional)
  static pw.Widget _buildClassicCard(
    Voucher voucher,
    pw.Font fontTitle,
    pw.Font fontBody,
    pw.Font fontMono,
    String? businessName,
    String? loginUrl,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(businessName ?? 'WASSAL WiFi', style: pw.TextStyle(font: fontTitle, fontSize: 10)),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  color: PdfColors.grey200,
                  child: pw.Text('${voucher.price} SDG', style: pw.TextStyle(font: fontTitle, fontSize: 9)),
                ),
              ],
          ),
          pw.Divider(height: 6, thickness: 0.5, color: PdfColors.grey300),
          pw.Expanded(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Username:', style: pw.TextStyle(font: fontBody, fontSize: 8, color: PdfColors.grey700)),
                pw.Text(voucher.username, style: pw.TextStyle(font: fontMono, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (voucher.password.isNotEmpty && voucher.password != voucher.username) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('Password:', style: pw.TextStyle(font: fontBody, fontSize: 8, color: PdfColors.grey700)),
                  pw.Text(voucher.password, style: pw.TextStyle(font: fontMono, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ],
            ),
          ),
          pw.Divider(height: 6, thickness: 0.5, color: PdfColors.grey300),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(voucher.planName, style: pw.TextStyle(font: fontTitle, fontSize: 8)),
              pw.Text(loginUrl ?? 'http://mikrotik', style: pw.TextStyle(font: fontBody, fontSize: 6, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Modern Design (Rounded, header background, focused on aesthetics)
  static pw.Widget _buildModernCard(
    Voucher voucher,
    pw.Font fontTitle,
    pw.Font fontBody,
    pw.Font fontMono,
    String? businessName,
    String? loginUrl,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        // color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const pw.BoxDecoration(
              color: PdfAppColors.primary,
              borderRadius: pw.BorderRadius.only(topLeft: pw.Radius.circular(9), topRight: pw.Radius.circular(9)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                   businessName?.toUpperCase() ?? 'WIFI VOUCHER',
                   style: pw.TextStyle(font: fontTitle, fontSize: 9, color: PdfColors.white)
                ),
                pw.Text(
                   '${voucher.price.toStringAsFixed(0)}',
                   style: pw.TextStyle(font: fontTitle, fontSize: 11, color: PdfAppColors.accent)
                ),
              ],
            ),
          ),
          
          // Body
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    voucher.username,
                    style: pw.TextStyle(font: fontMono, fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfAppColors.primary),
                  ),
                  if (voucher.password.isNotEmpty && voucher.password != voucher.username)
                    pw.Text(
                      voucher.password,
                      style: pw.TextStyle(font: fontMono, fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfAppColors.primaryLight),
                    ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    voucher.planName,
                    style: pw.TextStyle(font: fontBody, fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Minimal Design (Ink saving, text focused)
  static pw.Widget _buildMinimalCard(
    Voucher voucher,
    pw.Font fontTitle,
    pw.Font fontBody,
    pw.Font fontMono,
    String? businessName,
    String? loginUrl,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, style: pw.BorderStyle.dashed)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text("${businessName ?? 'WiFi'} - ${voucher.planName}", style: pw.TextStyle(font: fontBody, fontSize: 8)),
                pw.SizedBox(height: 2),
                pw.Text(voucher.username, style: pw.TextStyle(font: fontMono, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                if (voucher.password.isNotEmpty && voucher.password != voucher.username)
                  pw.Text(voucher.password, style: pw.TextStyle(font: fontMono, fontSize: 12)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                 pw.Text('${voucher.price} SDG', style: pw.TextStyle(font: fontTitle, fontSize: 10)),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildThermalCard(
    Voucher voucher,
    double widthMm,
    VoucherDesignTheme theme,
    pw.Font fontTitle,
    pw.Font fontBody,
    pw.Font fontMono, {
    String? businessName,
    String? loginUrl,
  }) {
    // Simplified thermal layout logic, can be expanded to themes too
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(businessName ?? 'WIFI VOUCHER', style: pw.TextStyle(font: fontTitle, fontSize: 14)),
        pw.SizedBox(height: 5),
        pw.Text('${voucher.price} SDG', style: pw.TextStyle(font: fontTitle, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: 'http://hotspot/login?username=${voucher.username}&password=${voucher.password}',
          width: widthMm * 1.5,
          height: widthMm * 1.5,
        ),
        pw.SizedBox(height: 8),
        pw.Text('CODE:', style: pw.TextStyle(font: fontBody, fontSize: 8)),
        pw.Text(voucher.username, style: pw.TextStyle(font: fontMono, fontSize: 20, fontWeight: pw.FontWeight.bold)),
        if (voucher.password.isNotEmpty && voucher.password != voucher.username) ...[
          pw.Text('PASSWORD:', style: pw.TextStyle(font: fontBody, fontSize: 8)),
          pw.Text(voucher.password, style: pw.TextStyle(font: fontMono, fontSize: 18)),
        ],
        pw.SizedBox(height: 8),
        pw.Text(voucher.planName, style: pw.TextStyle(font: fontBody, fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(loginUrl ?? 'http://mikrotik', style: pw.TextStyle(font: fontBody, fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
      ],
    );
  }
}





