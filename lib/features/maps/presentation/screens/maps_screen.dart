import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_ai/core/theme/app_theme.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/cosmic_background.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/glass_card.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  static const routeName = '/maps';

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;
  StreamSubscription<Position>? _positionSubscription;
  
  Position? _currentPosition;
  String _status = 'SCANNING FOR SIGNAL...';
  bool _isLocating = false;
  double _altitude = 0.0;
  double _accuracy = 0.0;

  @override
  void initState() {
    super.initState();
    // 1. Radar sweep rotation loop
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 2. Safely trigger position retrieval sequence
    _initLocationTracking();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
    if (!mounted) return;
    setState(() {
      _isLocating = true;
      _status = 'REQUESTING ACCESS PORTS...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _status = 'ACCESS PORT BLOCKED (DENIED)';
              _isLocating = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _status = 'ACCESS DENIED FOREVER';
            _isLocating = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _status = 'LOCKING SATELLITE VECTOR...';
        });
      }

      // Query current position once
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _altitude = position.altitude;
          _accuracy = position.accuracy;
          _isLocating = false;
          _status = 'VECTOR LOCK STABLE';
        });
      }

      // Open reactive positioning stream
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (Position pos) {
          if (mounted) {
            setState(() {
              _currentPosition = pos;
              _altitude = pos.altitude;
              _accuracy = pos.accuracy;
              _status = 'TELEMETRY STREAM ACTIVE';
            });
          }
        },
        onError: (err) {
          if (mounted) {
            setState(() {
              _status = 'SENSOR DIAGNOSTIC ERROR';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'COULD NOT DETECT CHIPS';
          _isLocating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A. Cockpit Top Navigator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'SENSOR TELEMETRY HUD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
                      onPressed: _initLocationTracking,
                      tooltip: 'Re-calibrate Sensors',
                    ),
                  ],
                ),
              ),

              // B. Glowing Space Radar sweep console
              Expanded(
                flex: 4,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating radar painter
                          CustomPaint(
                            size: const Size(260, 260),
                            painter: _RadarPainter(
                              angle: _radarController.value * math.pi * 2,
                              isActive: _currentPosition != null,
                            ),
                          ),

                          // Orbiting coordinates dot lock
                          if (_currentPosition != null)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(seconds: 1),
                              builder: (context, val, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    math.sin(_radarController.value * math.pi * 2) * 50 * val,
                                    math.cos(_radarController.value * math.pi * 2) * 50 * val,
                                  ),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary,
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // C. Glassmorphic Cockpit Telemetry Dashboard Cards
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.secondary.withOpacity(0.35),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Core status banner
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isLocating ? Colors.orange : AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _status,
                              style: TextStyle(
                                color: _isLocating ? Colors.orange : AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 24),

                        // Stats columns
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTelemetryBlock(
                                  label: 'LATITUDE VECTOR',
                                  value: _currentPosition != null 
                                      ? _currentPosition!.latitude.toStringAsFixed(6) 
                                      : 'NO_LOCK',
                                ),
                              ),
                              const VerticalDivider(color: Colors.white10, width: 24),
                              Expanded(
                                child: _buildTelemetryBlock(
                                  label: 'LONGITUDE VECTOR',
                                  value: _currentPosition != null 
                                      ? _currentPosition!.longitude.toStringAsFixed(6) 
                                      : 'NO_LOCK',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTelemetryBlock(
                                  label: 'ALTITUDE / SCAN',
                                  value: _currentPosition != null 
                                      ? '${_altitude.toStringAsFixed(1)} M' 
                                      : '0.0 M',
                                ),
                              ),
                              const VerticalDivider(color: Colors.white10, width: 24),
                              Expanded(
                                child: _buildTelemetryBlock(
                                  label: 'ACCURACY STABILIZER',
                                  value: _currentPosition != null 
                                      ? '${_accuracy.toStringAsFixed(1)} M' 
                                      : '0.0 M',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryBlock({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.angle, required this.isActive});

  final double angle;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.secondary.withOpacity(0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Draw concentrical target lines
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawCircle(center, radius * 0.4, paint);

    // 2. Draw cross hairs
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), paint);

    // 3. Draw scanning sweep gradient slice
    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        colors: [
          AppColors.secondary.withOpacity(0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.28],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.isActive != isActive;
  }
}
