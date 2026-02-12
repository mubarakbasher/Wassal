import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../domain/entities/voucher.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VoucherImageGenerator {
  /// Generate a styled PNG image for a single voucher
  static Future<Uint8List> generateImage(
    Voucher voucher, {
    String? businessName,
    String? loginUrl,
  }) async {
    // Create a picture recorder to capture the canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    const width = 400.0;
    const height = 500.0;
    
    // Draw the voucher card
    _drawVoucherCard(
      canvas, 
      voucher,
      width: width,
      height: height,
      businessName: businessName ?? 'WASSAL HOTSPOT',
      loginUrl: loginUrl ?? 'http://mikrotik',
    );
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  /// Generate and share voucher as image
  static Future<void> shareAsImage(
    BuildContext context,
    Voucher voucher, {
    String? businessName,
    String? loginUrl,
  }) async {
    try {
      final imageBytes = await generateImage(
        voucher,
        businessName: businessName,
        loginUrl: loginUrl,
      );
      
      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/voucher_${voucher.username}.png');
      await file.writeAsBytes(imageBytes);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'WiFi Voucher Code: ${voucher.username}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Generate and share multiple vouchers as a single image
  static Future<void> shareMultipleAsImage(
    BuildContext context,
    List<Voucher> vouchers, {
    String? businessName,
    String? loginUrl,
  }) async {
    try {
      final imageBytes = await _generateMultipleVouchersImage(
        vouchers,
        businessName: businessName ?? 'WASSAL HOTSPOT',
        loginUrl: loginUrl ?? 'http://mikrotik',
      );
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/vouchers_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${vouchers.length} WiFi Vouchers',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  static void _drawVoucherCard(
    Canvas canvas,
    Voucher voucher, {
    required double width,
    required double height,
    required String businessName,
    required String loginUrl,
  }) {
    // Background gradient
    final bgRect = Rect.fromLTWH(0, 0, width, height);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E3A5F), Color(0xFF2E5A8B)],
      ).createShader(bgRect);
    
    // Draw rounded rectangle background
    final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(24));
    canvas.drawRRect(rrect, bgPaint);
    
    // Draw subtle pattern overlay
    final patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(width * 0.1 * i, height * 0.15 * i),
        50,
        patternPaint,
      );
    }
    
    // Header - Business name
    final headerPainter = TextPainter(
      text: TextSpan(
        text: businessName,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    headerPainter.layout();
    headerPainter.paint(canvas, Offset((width - headerPainter.width) / 2, 30));
    
    // Price badge
    final priceRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(width / 2, 80), width: 120, height: 40),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      priceRect,
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );
    
    final pricePainter = TextPainter(
      text: TextSpan(
        text: '\$${voucher.price.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pricePainter.layout();
    pricePainter.paint(canvas, Offset((width - pricePainter.width) / 2, 70));
    
    // QR Code placeholder (white box)
    final qrRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(width / 2, 190), width: 140, height: 140),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      qrRect,
      Paint()..color = Colors.white,
    );
    
    // QR placeholder icon
    final qrIconPainter = TextPainter(
      text: const TextSpan(
        text: 'QR',
        style: TextStyle(
          color: Color(0xFF1E3A5F),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    qrIconPainter.layout();
    qrIconPainter.paint(canvas, Offset((width - qrIconPainter.width) / 2, 175));
    
    // Username label
    final userLabelPainter = TextPainter(
      text: const TextSpan(
        text: 'USERNAME',
        style: TextStyle(
          color: Colors.white60,
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    userLabelPainter.layout();
    userLabelPainter.paint(canvas, Offset((width - userLabelPainter.width) / 2, 290));
    
    // Username value
    final userPainter = TextPainter(
      text: TextSpan(
        text: voucher.username,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    userPainter.layout();
    userPainter.paint(canvas, Offset((width - userPainter.width) / 2, 310));
    
    // Password (if different)
    double nextY = 360;
    if (voucher.password.isNotEmpty && voucher.password != voucher.username) {
      final passLabelPainter = TextPainter(
        text: const TextSpan(
          text: 'PASSWORD',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      passLabelPainter.layout();
      passLabelPainter.paint(canvas, Offset((width - passLabelPainter.width) / 2, nextY));
      
      final passPainter = TextPainter(
        text: TextSpan(
          text: voucher.password,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      passPainter.layout();
      passPainter.paint(canvas, Offset((width - passPainter.width) / 2, nextY + 20));
      nextY = 420;
    }
    
    // Plan name
    final planPainter = TextPainter(
      text: TextSpan(
        text: voucher.planName,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    planPainter.layout();
    planPainter.paint(canvas, Offset((width - planPainter.width) / 2, nextY));
    
    // Footer - Login URL
    final footerPainter = TextPainter(
      text: TextSpan(
        text: loginUrl,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    footerPainter.layout();
    footerPainter.paint(canvas, Offset((width - footerPainter.width) / 2, height - 40));
  }

  static Future<Uint8List> _generateMultipleVouchersImage(
    List<Voucher> vouchers, {
    required String businessName,
    required String loginUrl,
  }) async {
    const cardWidth = 350.0;
    const cardHeight = 180.0;
    const padding = 16.0;
    
    final columns = 2;
    final rows = (vouchers.length / columns).ceil();
    
    final totalWidth = (cardWidth * columns) + (padding * (columns + 1));
    final totalHeight = (cardHeight * rows) + (padding * (rows + 1)) + 80; // Extra for header
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Background
    final bgPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRect(Rect.fromLTWH(0, 0, totalWidth, totalHeight), bgPaint);
    
    // Header
    final headerPainter = TextPainter(
      text: TextSpan(
        text: businessName,
        style: const TextStyle(
          color: Color(0xFF1E3A5F),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    headerPainter.layout();
    headerPainter.paint(canvas, Offset((totalWidth - headerPainter.width) / 2, 20));
    
    final subPainter = TextPainter(
      text: TextSpan(
        text: '${vouchers.length} Vouchers',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subPainter.layout();
    subPainter.paint(canvas, Offset((totalWidth - subPainter.width) / 2, 50));
    
    // Draw each voucher card
    for (int i = 0; i < vouchers.length; i++) {
      final col = i % columns;
      final row = i ~/ columns;
      
      final x = padding + (col * (cardWidth + padding));
      final y = 80 + padding + (row * (cardHeight + padding));
      
      _drawCompactVoucherCard(
        canvas,
        vouchers[i],
        Offset(x, y),
        cardWidth,
        cardHeight,
      );
    }
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  static void _drawCompactVoucherCard(
    Canvas canvas,
    Voucher voucher,
    Offset offset,
    double width,
    double height,
  ) {
    final rect = Rect.fromLTWH(offset.dx, offset.dy, width, height);
    
    // Card background
    final cardPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E3A5F), Color(0xFF2E5A8B)],
      ).createShader(rect);
    
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, cardPaint);
    
    // Username
    final userPainter = TextPainter(
      text: TextSpan(
        text: voucher.username,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    userPainter.layout();
    userPainter.paint(
      canvas,
      Offset(offset.dx + 20, offset.dy + 30),
    );
    
    // Password if different
    if (voucher.password.isNotEmpty && voucher.password != voucher.username) {
      final passPainter = TextPainter(
        text: TextSpan(
          text: 'Pass: ${voucher.password}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      passPainter.layout();
      passPainter.paint(
        canvas,
        Offset(offset.dx + 20, offset.dy + 60),
      );
    }
    
    // Plan name
    final planPainter = TextPainter(
      text: TextSpan(
        text: voucher.planName,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    planPainter.layout();
    planPainter.paint(
      canvas,
      Offset(offset.dx + 20, offset.dy + height - 40),
    );
    
    // Price badge
    final priceRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx + width - 90, offset.dy + 20, 70, 30),
      const Radius.circular(15),
    );
    canvas.drawRRect(
      priceRect,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
    
    final pricePainter = TextPainter(
      text: TextSpan(
        text: '\$${voucher.price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pricePainter.layout();
    pricePainter.paint(
      canvas,
      Offset(offset.dx + width - 90 + (70 - pricePainter.width) / 2, offset.dy + 28),
    );
  }
}
