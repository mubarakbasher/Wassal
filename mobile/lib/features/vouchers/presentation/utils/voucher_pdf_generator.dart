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
  static String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours < 24) return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    final days = hours ~/ 24;
    final remHours = hours % 24;
    if (remHours > 0) return '${days}d ${remHours}h';
    return '${days}d';
  }

  static String _formatDataLimit(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String _formatPrice(double price) {
    final formatted = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(1);
    return '$formatted SDG';
  }

  static String? _limitLabel(Voucher voucher) {
    final parts = <String>[];
    if (voucher.duration != null && voucher.duration! > 0) {
      parts.add(_formatDuration(voucher.duration!));
    }
    if (voucher.dataLimit != null && voucher.dataLimit! > 0) {
      parts.add(_formatDataLimit(voucher.dataLimit!));
    }
    return parts.isEmpty ? null : parts.join(' / ');
  }

  static pw.Font? _cachedFontTitle;
  static pw.Font? _cachedFontBody;
  static pw.Font? _cachedFontMono;

  static Future<({pw.Font title, pw.Font body, pw.Font mono})> _loadFonts() async {
    try {
      _cachedFontTitle ??= await PdfGoogleFonts.nunitoBold();
      _cachedFontBody ??= await PdfGoogleFonts.nunitoRegular();
      _cachedFontMono ??= await PdfGoogleFonts.jetBrainsMonoBold();
      return (title: _cachedFontTitle!, body: _cachedFontBody!, mono: _cachedFontMono!);
    } catch (_) {
      final fallback = pw.Font.helvetica();
      final fallbackBold = pw.Font.helveticaBold();
      final fallbackMono = pw.Font.courier();
      _cachedFontTitle = fallbackBold;
      _cachedFontBody = fallback;
      _cachedFontMono = fallbackMono;
      return (title: fallbackBold, body: fallback, mono: fallbackMono);
    }
  }

  /// Generate PDF with customizable layout and design
  static Future<Uint8List> generate(
    List<Voucher> vouchers, {
    PrinterFormat format = PrinterFormat.a4,
    VoucherDesignTheme theme = VoucherDesignTheme.classic,
    int columns = 2,
    String? businessName,
    String? loginUrl,
  }) async {
    if (vouchers.isEmpty) {
      final doc = pw.Document();
      doc.addPage(pw.Page(build: (_) => pw.Center(child: pw.Text('No vouchers to print'))));
      return doc.save();
    }
    switch (format) {
      case PrinterFormat.a4:
        return _generateA4(
          vouchers, 
          columns: columns, 
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
    required VoucherDesignTheme theme,
    String? businessName,
    String? loginUrl,
  }) async {
    final doc = pw.Document();
    
    final fonts = await _loadFonts();
    final fontTitle = fonts.title;
    final fontBody = fonts.body;
    final fontMono = fonts.mono;

    // Calculate dimensions
    const pageFormat = PdfPageFormat.a4;
    const margin = 15.0; // mm
    const spacing = 5.0; // mm
    
    // Available width/height for vouchers in points (use full page dimensions since
    // the pw.Page margin already constrains the rendering area)
    final contentWidth = pageFormat.width - (margin * PdfPageFormat.mm * 2);
    final contentHeight = pageFormat.height - (margin * PdfPageFormat.mm * 2);
    
    // Calculate card width from columns
    final cardWidth = (contentWidth - ((columns - 1) * spacing * PdfPageFormat.mm)) / columns;
    // Card height from aspect ratio (~1.8:1)
    final cardHeight = cardWidth * 0.55;
    // Auto-calculate how many rows fit on the page
    final rows = ((contentHeight + spacing * PdfPageFormat.mm) / (cardHeight + spacing * PdfPageFormat.mm)).floor().clamp(1, 20);

    // Scale factor: compare current card size to default (2 cols x 5 rows) baseline
    const baseCardWidth = 220.0;
    const baseCardHeight = 120.0;
    final scaleX = cardWidth / baseCardWidth;
    final scaleY = cardHeight / baseCardHeight;
    final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.3, 1.5);

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
                    scale: scale,
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
    final fonts = await _loadFonts();
    final fontTitle = fonts.title;
    final fontBody = fonts.body;
    final fontMono = fonts.mono;

    final pageWidth = widthMm * PdfPageFormat.mm;
    
    // For thermal, we typically print one long roll or paginate per voucher.
    // Here we paginate per voucher for cleaner cuts.
    for (final voucher in vouchers) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, pageWidth * 3),
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
    double scale = 1.0,
    String? businessName,
    String? loginUrl,
  }) {
    switch (theme) {
      case VoucherDesignTheme.modern:
        return _buildModernCard(voucher, fontTitle, fontBody, fontMono, businessName, loginUrl, scale);
      case VoucherDesignTheme.minimal:
        return _buildMinimalCard(voucher, fontTitle, fontBody, fontMono, businessName, loginUrl, scale);
      case VoucherDesignTheme.classic:
        return _buildClassicCard(voucher, fontTitle, fontBody, fontMono, businessName, loginUrl, scale);
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
    double scale,
  ) {
    final s = scale;
    final priceStr = _formatPrice(voucher.price);
    final limit = _limitLabel(voucher);
    return pw.Container(
      padding: pw.EdgeInsets.all(8 * s),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5 * s),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6 * s)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(businessName ?? 'WASSAL WiFi', style: pw.TextStyle(font: fontTitle, fontSize: 10 * s)),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 4 * s, vertical: 1 * s),
                  color: PdfColors.grey200,
                  child: pw.Text(priceStr, style: pw.TextStyle(font: fontTitle, fontSize: 9 * s)),
                ),
              ],
          ),
          pw.Divider(height: 6 * s, thickness: 0.5, color: PdfColors.grey300),
          pw.Expanded(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Username:', style: pw.TextStyle(font: fontBody, fontSize: 8 * s, color: PdfColors.grey700)),
                pw.Text(voucher.username, style: pw.TextStyle(font: fontMono, fontSize: 14 * s, fontWeight: pw.FontWeight.bold)),
                if (voucher.password.isNotEmpty && voucher.password != voucher.username) ...[
                  pw.SizedBox(height: 4 * s),
                  pw.Text('Password:', style: pw.TextStyle(font: fontBody, fontSize: 8 * s, color: PdfColors.grey700)),
                  pw.Text(voucher.password, style: pw.TextStyle(font: fontMono, fontSize: 14 * s, fontWeight: pw.FontWeight.bold)),
                ],
              ],
            ),
          ),
          pw.Divider(height: 6 * s, thickness: 0.5, color: PdfColors.grey300),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(voucher.planName, style: pw.TextStyle(font: fontTitle, fontSize: 8 * s)),
              if (limit != null)
                pw.Text(limit, style: pw.TextStyle(font: fontTitle, fontSize: 10 * s, color: PdfAppColors.primary))
              else
                pw.Text(loginUrl ?? '', style: pw.TextStyle(font: fontBody, fontSize: 6 * s, color: PdfColors.grey600)),
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
    double scale,
  ) {
    final s = scale;
    final radius = 10.0 * s;
    final priceStr = _formatPrice(voucher.price);
    final limit = _limitLabel(voucher);
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5 * s),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(radius)),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
            decoration: pw.BoxDecoration(
              color: PdfAppColors.primary,
              borderRadius: pw.BorderRadius.only(topLeft: pw.Radius.circular(radius - 0.5), topRight: pw.Radius.circular(radius - 0.5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                   businessName?.toUpperCase() ?? 'WIFI VOUCHER',
                   style: pw.TextStyle(font: fontTitle, fontSize: 9 * s, color: PdfColors.white)
                ),
                pw.Text(
                   priceStr,
                   style: pw.TextStyle(font: fontTitle, fontSize: 11 * s, color: PdfAppColors.accent)
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.all(6 * s),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    voucher.username,
                    style: pw.TextStyle(font: fontMono, fontSize: 13 * s, fontWeight: pw.FontWeight.bold, color: PdfAppColors.primary),
                  ),
                  if (voucher.password.isNotEmpty && voucher.password != voucher.username)
                    pw.Text(
                      voucher.password,
                      style: pw.TextStyle(font: fontMono, fontSize: 13 * s, fontWeight: pw.FontWeight.bold, color: PdfAppColors.primaryLight),
                    ),
                  pw.SizedBox(height: 2 * s),
                  pw.Row(
                    children: [
                      pw.Text(
                        voucher.planName,
                        style: pw.TextStyle(font: fontBody, fontSize: 8 * s, color: PdfColors.grey600),
                      ),
                      if (limit != null) ...[
                        pw.SizedBox(width: 6 * s),
                        pw.Text(
                          limit,
                          style: pw.TextStyle(font: fontTitle, fontSize: 10 * s, color: PdfAppColors.accent),
                        ),
                      ],
                    ],
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
    double scale,
  ) {
    final s = scale;
    final priceStr = _formatPrice(voucher.price);
    final limit = _limitLabel(voucher);
    return pw.Container(
      padding: pw.EdgeInsets.all(4 * s),
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
                pw.Text("${businessName ?? 'WiFi'} - ${voucher.planName}", style: pw.TextStyle(font: fontBody, fontSize: 8 * s)),
                pw.SizedBox(height: 2 * s),
                pw.Text(voucher.username, style: pw.TextStyle(font: fontMono, fontSize: 16 * s, fontWeight: pw.FontWeight.bold)),
                if (voucher.password.isNotEmpty && voucher.password != voucher.username)
                  pw.Text(voucher.password, style: pw.TextStyle(font: fontMono, fontSize: 12 * s)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                 pw.Text(priceStr, style: pw.TextStyle(font: fontTitle, fontSize: 10 * s)),
                 if (limit != null)
                   pw.Text(limit, style: pw.TextStyle(font: fontTitle, fontSize: 10 * s)),
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
    final base = loginUrl ?? 'http://hotspot/login';
    final qrData = '$base?username=${Uri.encodeComponent(voucher.username)}&password=${Uri.encodeComponent(voucher.password)}';
    final qrSize = (widthMm - 8) * PdfPageFormat.mm * 0.6;
    final priceStr = _formatPrice(voucher.price);
    final limit = _limitLabel(voucher);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(businessName ?? 'WIFI VOUCHER', style: pw.TextStyle(font: fontTitle, fontSize: 14)),
        pw.SizedBox(height: 5),
        pw.Text(priceStr, style: pw.TextStyle(font: fontTitle, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: qrData,
          width: qrSize,
          height: qrSize,
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
        if (limit != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(limit, style: pw.TextStyle(font: fontTitle, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
        pw.SizedBox(height: 4),
        pw.Text(base, style: pw.TextStyle(font: fontBody, fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
      ],
    );
  }
}

