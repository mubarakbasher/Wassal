import 'package:flutter/material.dart';

/// Animated text widget that smoothly transitions between status messages
class StatusTextAnimator extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration transitionDuration;

  const StatusTextAnimator({
    super.key,
    required this.text,
    this.style,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  State<StatusTextAnimator> createState() => _StatusTextAnimatorState();
}

class _StatusTextAnimatorState extends State<StatusTextAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _currentText = '';
  String _nextText = '';
  bool _showNext = false;

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    
    _controller = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentText = _nextText;
          _showNext = false;
        });
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(StatusTextAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && widget.text.isNotEmpty) {
      _nextText = widget.text;
      _showNext = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 16,
      color: Colors.white.withValues(alpha: 0.8),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Current text (fading out and sliding up)
            SlideTransition(
              position: _slideAnimation,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  _currentText,
                  style: widget.style ?? defaultStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Next text (fading in and sliding up)
            if (_showNext)
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                )),
                child: Opacity(
                  opacity: 1 - _fadeAnimation.value,
                  child: Text(
                    _nextText,
                    style: widget.style ?? defaultStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
