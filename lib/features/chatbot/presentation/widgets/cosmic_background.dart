import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nexa_ai/core/theme/app_theme.dart';

class CosmicBackground extends StatefulWidget {
  const CosmicBackground({
    super.key,
    required this.child,
    this.scrollOffset = 0.0,
  });

  final Widget child;
  final double scrollOffset;

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _starController;
  final List<_Star> _stars = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Generate 60 stars across three depth classes
    for (int i = 0; i < 60; i++) {
      _stars.add(
        _Star(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 2.2 + 0.6,
          depth: _random.nextInt(3) + 1, // 1 (far), 2 (mid), 3 (near)
          pulseSpeed: _random.nextDouble() * 3.0 + 1.0,
          initialPhase: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _starController,
        builder: (context, child) {
          return CustomPaint(
            painter: _CosmicPainter(
              stars: _stars,
              animProgress: _starController.value,
              scrollOffset: widget.scrollOffset,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.depth,
    required this.pulseSpeed,
    required this.initialPhase,
  });

  final double x;
  final double y;
  final double size;
  final int depth;
  final double pulseSpeed;
  final double initialPhase;
}

class _CosmicPainter extends CustomPainter {
  _CosmicPainter({
    required this.stars,
    required this.animProgress,
    required this.scrollOffset,
  });

  final List<_Star> stars;
  final double animProgress;
  final double scrollOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw Space Atmospheric Background Gradient
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = RadialGradient(
      center: const Alignment(-0.6, -0.7),
      radius: 1.5,
      colors: [
        const Color(0xFF100B2E).withAlpha(160), // Nebula glow top-left
        AppColors.background,
      ],
      stops: const [0.0, 0.7],
    );
    paint.shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, paint);

    // 2. Draw Translucent Secondary Color Nebula sweeps
    final nebulaRect = Rect.fromCircle(
      center: Offset(size.width * 0.8, size.height * 0.75),
      radius: size.width * 0.65,
    );
    final nebulaGradient = RadialGradient(
      colors: [
        AppColors.accent.withAlpha(20), // Soft Aurora purple glow
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
    paint.shader = nebulaGradient.createShader(nebulaRect);
    canvas.drawCircle(nebulaRect.center, nebulaRect.width / 2, paint);

    // 3. Draw Stars with pulse cycles and depth parallax offsets
    paint.shader = null;
    for (final star in stars) {
      // Calculate depth parallax offset based on scrolls and time
      final speedFactor = star.depth * 0.04;
      final yOffset = (scrollOffset * speedFactor) % size.height;
      final timeOffset = (animProgress * size.height * (star.depth * 0.1)) % size.height;

      final double starX = (star.x * size.width) % size.width;
      final double starY = (star.y * size.height - yOffset - timeOffset) % size.height;

      // Wrap-around coordinates to keep stars on the screen
      final finalX = starX < 0 ? starX + size.width : starX;
      final finalY = starY < 0 ? starY + size.height : starY;

      // Pulse brightness
      final pulsePhase = animProgress * math.pi * 2 * star.pulseSpeed + star.initialPhase;
      final opacity = (math.sin(pulsePhase) * 0.45 + 0.55).clamp(0.2, 1.0);

      paint.color = Colors.white.withOpacity(opacity);

      // Render star
      canvas.drawCircle(Offset(finalX, finalY), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress || oldDelegate.scrollOffset != scrollOffset;
  }
}
