import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_ai/features/chatbot/presentation/providers/personality_provider.dart';

class FloatingAvatar extends ConsumerStatefulWidget {
  const FloatingAvatar({
    super.key,
    required this.isBusy,
    this.size = 90.0,
  });

  final bool isBusy;
  final double size;

  @override
  ConsumerState<FloatingAvatar> createState() => _FloatingAvatarState();
}

class _FloatingAvatarState extends ConsumerState<FloatingAvatar> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // 1. Smooth up/down floating physics
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 2. Continuous rotation for the orbital rings
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 3. Ripple pulse waves for AI thinking states
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.isBusy) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FloatingAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBusy != oldWidget.isBusy) {
      if (widget.isBusy) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activePersonality = ref.watch(activePersonalityProvider);
    final accentColor = activePersonality.accentColor;

    return SizedBox(
      width: widget.size + 40,
      height: widget.size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A. Pulsing ripple waves (Outer glow pulses when busy)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final opacity = (1.0 - _pulseController.value).clamp(0.0, 0.7);
              final scale = 1.0 + (_pulseController.value * 0.45);

              return Opacity(
                opacity: widget.isBusy ? opacity : 0.0,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // B. Star-sphere core (Floating breathing capsule)
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final double floatY = math.sin(_floatController.value * math.pi * 2) * 8.0;

              return Transform.translate(
                offset: Offset(0.0, floatY),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating planetary rings
                    AnimatedBuilder(
                      animation: _orbitController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _orbitController.value * math.pi * 2,
                          child: CustomPaint(
                            size: Size(widget.size + 24, widget.size + 24),
                            painter: _OrbitRingPainter(color: accentColor),
                          ),
                        );
                      },
                    ),

                    // Central glowing sphere core
                    Container(
                      width: widget.size - 10,
                      height: widget.size - 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.3),
                          radius: 0.85,
                          colors: [
                            Colors.white,
                            accentColor.withOpacity(0.85),
                            accentColor.withOpacity(0.2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.55),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          activePersonality.avatarEmoji,
                          style: TextStyle(
                            fontSize: widget.size * 0.42,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  _OrbitRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw primary orbit ring
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height * 0.28,
      ),
      paint,
    );

    // Draw little orbital particle on the ring
    final particlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.5),
      3.5,
      particlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
