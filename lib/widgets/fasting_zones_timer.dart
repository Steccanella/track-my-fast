import 'package:flutter/material.dart';
import 'dart:math' as math;

class FastingZonesTimer extends StatelessWidget {
  final double progress;
  final Duration elapsedTime;
  final Duration remainingTime;
  final Duration targetDuration;
  final bool isActive;
  final bool isOvertime;
  final Widget centerContent;

  const FastingZonesTimer({
    super.key,
    required this.progress,
    required this.elapsedTime,
    required this.remainingTime,
    required this.targetDuration,
    required this.isActive,
    required this.isOvertime,
    required this.centerContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: const Size(320, 320),
            painter: FastingZonesPainter(
              progress: progress,
              elapsedTime: elapsedTime,
              targetDuration: targetDuration,
              isActive: isActive,
            ),
          ),

          // Zone labels - always show them for reference
          ..._buildZoneLabels(),

          // Center content
          SizedBox(
            width: 200,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: centerContent),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildZoneLabels() {
    final zones = [
      {'name': 'Anabolic', 'emoji': '🍽️', 'startHour': 0, 'endHour': 4},
      {'name': 'Catabolic', 'emoji': '💪', 'startHour': 4, 'endHour': 16},
      {'name': 'Fat Burning', 'emoji': '🔥', 'startHour': 16, 'endHour': 24},
      {'name': 'Ketosis', 'emoji': '⚡', 'startHour': 24, 'endHour': 72},
    ];

    final elapsedHours = elapsedTime.inHours.toDouble();

    return zones.map((zone) {
      final startHour = zone['startHour'] as int;
      final endHour = zone['endHour'] as int;
      final isCurrentZone =
          isActive && elapsedHours >= startHour && elapsedHours < endHour;
      final isPastZone = isActive && elapsedHours >= endHour;

      // Calculate the center angle of this zone segment (matching the painted zones)
      final totalHours = 72.0; // Total hours for full circle
      final startAngle = -math.pi / 2 + (2 * math.pi * startHour / totalHours);
      final endAngle = -math.pi / 2 + (2 * math.pi * endHour / totalHours);
      final centerAngle = (startAngle + endAngle) / 2;

      // Position the icon at the exact center of the bar stroke
      final containerSize = 320.0; // Total container size
      final iconRadius =
          containerSize / 2 - 20; // Same radius as the painter draws the arc

      final x = 160 + (iconRadius * math.cos(centerAngle)); // Center at 160,160
      final y = 160 + (iconRadius * math.sin(centerAngle));

      return Positioned(
        left: x - 22,
        top: y - 22,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isCurrentZone
                ? Colors.white
                : (isPastZone
                    ? Colors.white.withOpacity(0.95)
                    : Colors.white.withOpacity(0.8)),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentZone
                  ? _getZoneColor(zone['name'] as String)
                  : (isPastZone
                      ? _getZoneColor(zone['name'] as String).withOpacity(0.7)
                      : _getZoneColor(zone['name'] as String).withOpacity(0.4)),
              width: isCurrentZone ? 3 : (isPastZone ? 2 : 1),
            ),
            boxShadow: isCurrentZone
                ? [
                    BoxShadow(
                      color: _getZoneColor(zone['name'] as String)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : (isPastZone
                    ? [
                        BoxShadow(
                          color: _getZoneColor(zone['name'] as String)
                              .withOpacity(0.15),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                zone['emoji'] as String,
                style: TextStyle(
                  fontSize: isCurrentZone ? 18 : (isPastZone ? 16 : 14),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                zone['name'] as String,
                style: TextStyle(
                  fontSize: isCurrentZone ? 7 : 6,
                  fontWeight: isCurrentZone ? FontWeight.bold : FontWeight.w500,
                  color: isCurrentZone
                      ? _getZoneColor(zone['name'] as String)
                      : (isPastZone
                          ? _getZoneColor(zone['name'] as String)
                              .withOpacity(0.8)
                          : _getZoneColor(zone['name'] as String)
                              .withOpacity(0.6)),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getZoneColor(String zoneName) {
    switch (zoneName) {
      case 'Anabolic':
        return const Color(0xFFFFD93D); // Yellow
      case 'Catabolic':
        return const Color(0xFFFF6B6B); // Red
      case 'Fat Burning':
        return const Color(0xFF4ECDC4); // Teal
      case 'Ketosis':
        return const Color(0xFF45B7D1); // Blue
      default:
        return Colors.grey;
    }
  }
}

class FastingZonesPainter extends CustomPainter {
  final double progress;
  final Duration elapsedTime;
  final Duration targetDuration;
  final bool isActive;

  FastingZonesPainter({
    required this.progress,
    required this.elapsedTime,
    required this.targetDuration,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 20.0;

    // Define zones with their hour ranges and colors
    final zones = [
      {
        'start': 0,
        'end': 4,
        'color': const Color(0xFFFFD93D),
        'name': 'Anabolic'
      }, // 0-4h Yellow
      {
        'start': 4,
        'end': 16,
        'color': const Color(0xFFFF6B6B),
        'name': 'Catabolic'
      }, // 4-16h Red
      {
        'start': 16,
        'end': 24,
        'color': const Color(0xFF4ECDC4),
        'name': 'Fat Burning'
      }, // 16-24h Teal
      {
        'start': 24,
        'end': 72,
        'color': const Color(0xFF45B7D1),
        'name': 'Ketosis'
      }, // 24-72h Blue
    ];

    // Draw background zones
    for (int i = 0; i < zones.length; i++) {
      final zone = zones[i];
      final startAngle =
          -math.pi / 2 + (2 * math.pi * (zone['start'] as int) / 72);
      final sweepAngle =
          2 * math.pi * ((zone['end'] as int) - (zone['start'] as int)) / 72;

      final paint = Paint()
        ..color = (zone['color'] as Color).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    if (isActive && progress > 0) {
      // Calculate current zone based on elapsed time
      final currentHours = elapsedTime.inHours;

      // Draw progress arc with zone-appropriate color
      Color progressColor = const Color(0xFFFFD93D); // Default to anabolic

      if (currentHours >= 24) {
        progressColor = const Color(0xFF45B7D1); // Ketosis
      } else if (currentHours >= 16) {
        progressColor = const Color(0xFF4ECDC4); // Fat Burning
      } else if (currentHours >= 4) {
        progressColor = const Color(0xFFFF6B6B); // Catabolic
      }

      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round;

      // Use actual progress instead of calculating from hours
      final progressAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progressAngle,
        false,
        progressPaint,
      );

      // Draw a glowing effect at the progress end
      final glowPaint = Paint()
        ..color = progressColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round;

      final endAngle = -math.pi / 2 + progressAngle;
      final glowStartAngle = endAngle - 0.1;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        glowStartAngle,
        0.2,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(FastingZonesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.elapsedTime != elapsedTime ||
        oldDelegate.targetDuration != targetDuration ||
        oldDelegate.isActive != isActive;
  }
}
