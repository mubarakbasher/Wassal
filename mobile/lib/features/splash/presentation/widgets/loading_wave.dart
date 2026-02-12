import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated loading wave indicator
class LoadingWave extends StatefulWidget {
  final bool animate;
  final Color color;
  final double size;

  const LoadingWave({
    super.key,
    this.animate = true,
    this.color = const Color(0xFFFF4B5C),
    this.size = 50,
  });

  @override
  State<LoadingWave> createState() => _LoadingWaveState();
}

class _LoadingWaveState extends State<LoadingWave>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(5, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
    });

    _animations = _controllers.asMap().entries.map((entry) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: entry.value,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    if (widget.animate) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
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
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: widget.size * _animations[index].value,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.6 + (_animations[index].value * 0.4)),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Animated dots loading indicator
class LoadingDots extends StatefulWidget {
  final bool animate;
  final Color color;
  final double size;

  const LoadingDots({
    super.key,
    this.animate = true,
    this.color = const Color(0xFFFF4B5C),
    this.size = 12,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.animate) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -8 * _animations[index].value),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.5 + (_animations[index].value * 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3 * _animations[index].value),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
