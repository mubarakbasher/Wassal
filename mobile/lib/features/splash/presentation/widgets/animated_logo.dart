import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated logo widget with scale-up fade-in and pulse glow effect
class AnimatedLogo extends StatefulWidget {
  final bool animate;
  final Widget? logoWidget;
  final double size;

  const AnimatedLogo({
    super.key,
    this.animate = true,
    this.logoWidget,
    this.size = 120,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _fadeScaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fade and scale animation (0-1s)
    _fadeScaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeScaleController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeScaleController,
        curve: Curves.easeOutBack,
      ),
    );

    // Continuous pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _fadeScaleController.forward();
      _fadeScaleController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeScaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeScaleController, _pulseController]),
      builder: (context, child) {
        final pulseGlow = 15 + (_pulseAnimation.value * 20);
        
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4B5C).withValues(alpha: 0.3 + (_pulseAnimation.value * 0.2)),
                    blurRadius: pulseGlow,
                    spreadRadius: pulseGlow / 3,
                  ),
                  BoxShadow(
                    color: const Color(0xFF4ECCA3).withValues(alpha: 0.15 + (_pulseAnimation.value * 0.1)),
                    blurRadius: pulseGlow * 1.5,
                    spreadRadius: pulseGlow / 2,
                  ),
                ],
              ),
              child: widget.logoWidget ?? _buildDefaultLogo(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF4B5C),
            Color(0xFFD63447),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Network icon in center
            Icon(
              Icons.wifi_tethering,
              size: widget.size * 0.45,
              color: Colors.white,
            ),
            // Subtle ring effect
            Container(
              width: widget.size * 0.75,
              height: widget.size * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Network pulse rings animation overlay
class NetworkPulseRings extends StatefulWidget {
  final bool animate;
  final double size;

  const NetworkPulseRings({
    super.key,
    this.animate = true,
    this.size = 200,
  });

  @override
  State<NetworkPulseRings> createState() => _NetworkPulseRingsState();
}

class _NetworkPulseRingsState extends State<NetworkPulseRings>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    if (widget.animate) {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 800), () {
          if (mounted) {
            _controllers[i].repeat();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final value = _animations[index].value;
              final scale = 0.5 + (value * 0.5);
              final opacity = (1 - value) * 0.5;
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF4B5C).withValues(alpha: opacity),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
