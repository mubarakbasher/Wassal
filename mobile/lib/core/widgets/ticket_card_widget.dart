import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A ticket-style card with perforated edges for vouchers
class TicketCardWidget extends StatefulWidget {
  final String code;
  final String planName;
  final String status;
  final double price;
  final String? duration;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onMore;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const TicketCardWidget({
    super.key,
    required this.code,
    required this.planName,
    required this.status,
    required this.price,
    this.duration,
    this.onPrint,
    this.onShare,
    this.onMore,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  State<TicketCardWidget> createState() => _TicketCardWidgetState();
}

class _TicketCardWidgetState extends State<TicketCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Only pulse for active vouchers
    if (widget.status.toLowerCase() == 'active') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TicketCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status.toLowerCase() == 'active' && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.status.toLowerCase() != 'active' && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'active':
        return AppColors.active;
      case 'unused':
        return AppColors.unused;
      case 'expired':
        return AppColors.expired;
      case 'used':
        return AppColors.used;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      child: Stack(
        children: [
          CustomPaint(
            painter: TicketPainter(
              color: widget.isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.card,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              borderColor: widget.isSelected ? AppColors.primary : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.code,
                              style: AppTextStyles.voucherCode,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.planName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: widget.status.toLowerCase() == 'active' 
                                ? _pulseAnimation.value 
                                : 1.0,
                            child: child,
                          );
                        },
                        child: _buildStatusBadge(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Perforated line
                  Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index.isEven ? AppColors.divider : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '\$${widget.price.toStringAsFixed(2)}',
                              style: AppTextStyles.buttonSmall,
                            ),
                          ),
                          if (widget.duration != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cardElevated,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.duration!,
                                style: AppTextStyles.labelSmall,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (!widget.isSelected) // Hide actions when selecting
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              Icons.print_outlined,
                              onPressed: widget.onPrint,
                            ),
                            _buildActionButton(
                              Icons.share_outlined,
                              onPressed: widget.onShare,
                            ),
                            _buildActionButton(
                              Icons.more_horiz,
                              onPressed: widget.onMore,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.isSelected)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.status.toUpperCase(),
        style: AppTextStyles.badgeText.copyWith(
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, {VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw ticket with cutout edges
class TicketPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color? borderColor;
  final double notchRadius;

  TicketPainter({
    required this.color,
    required this.shadowColor,
    this.borderColor,
    this.notchRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = _getTicketPath(size);
    
    // Draw shadow
    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);
    
    // Draw ticket
    canvas.drawPath(path, paint);

    // Draw border if provided
    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0; // Thicker border for selection
      
      canvas.drawPath(path, borderPaint);
    }
  }

  Path _getTicketPath(Size size) {
    final path = Path();
    final notchY = size.height * 0.55; // Position of the notches

    path.moveTo(16, 0);
    
    // Top edge
    path.lineTo(size.width - 16, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 16);
    
    // Right edge to notch
    path.lineTo(size.width, notchY - notchRadius);
    
    // Right notch (semicircle cutout)
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Right edge from notch to bottom
    path.lineTo(size.width, size.height - 16);
    path.quadraticBezierTo(size.width, size.height, size.width - 16, size.height);
    
    // Bottom edge
    path.lineTo(16, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 16);
    
    // Left edge from bottom to notch
    path.lineTo(0, notchY + notchRadius);
    
    // Left notch (semicircle cutout)
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Left edge from notch to top
    path.lineTo(0, 16);
    path.quadraticBezierTo(0, 0, 16, 0);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated counter widget for stats
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle style;
  final String? prefix;
  final String? suffix;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.prefix,
    this.suffix,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value.toInt()}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// Gradient stats card widget
class GradientStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const GradientStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTextStyles.statValue,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.statLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// Staggered animation wrapper for list items
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration animationDuration;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 50),
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
