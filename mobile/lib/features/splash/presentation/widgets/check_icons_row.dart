import 'package:flutter/material.dart';
import '../bloc/splash_state.dart';

/// Row of animated check icons showing system check results
class CheckIconsRow extends StatelessWidget {
  final Map<SplashCheck, bool?> checkResults;
  final bool showIcons;

  const CheckIconsRow({
    super.key,
    required this.checkResults,
    this.showIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIcons) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CheckIcon(
          icon: Icons.wifi,
          label: 'Network',
          status: checkResults[SplashCheck.internet],
          delay: 0,
        ),
        const SizedBox(width: 32),
        _CheckIcon(
          icon: Icons.person_outline,
          label: 'Session',
          status: checkResults[SplashCheck.session],
          delay: 300,
        ),
        const SizedBox(width: 32),
        _CheckIcon(
          icon: Icons.check_circle_outline,
          label: 'Ready',
          status: checkResults[SplashCheck.server],
          delay: 600,
        ),
      ],
    );
  }
}

class _CheckIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool? status; // null = pending, true = success, false = error
  final int delay;

  const _CheckIcon({
    required this.icon,
    required this.label,
    required this.status,
    required this.delay,
  });

  @override
  State<_CheckIcon> createState() => _CheckIconState();
}

class _CheckIconState extends State<_CheckIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_CheckIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != null && !_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _iconColor {
    if (widget.status == null) {
      return const Color(0xFF3A3A5C);
    }
    return widget.status! 
        ? const Color(0xFF4CAF50) 
        : const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A2E),
                border: Border.all(
                  color: _iconColor.withValues(alpha: 0.5 + (_fadeAnimation.value * 0.5)),
                  width: 2,
                ),
                boxShadow: widget.status == true
                    ? [
                        BoxShadow(
                          color: _iconColor.withValues(alpha: 0.3 * _fadeAnimation.value),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.status == null
                    ? Icon(
                        widget.icon,
                        color: _iconColor,
                        size: 24,
                      )
                    : Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Icon(
                          widget.status!
                              ? Icons.check
                              : Icons.close,
                          color: _iconColor,
                          size: 28,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
