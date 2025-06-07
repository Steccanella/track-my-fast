import 'package:flutter/material.dart';
import '../models/weight_entry.dart';

class WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;

  const WeightChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: WeightChartPainter(entries),
        size: const Size.fromHeight(200),
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;

  WeightChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    // Sort entries by date
    final sortedEntries = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Find min and max weights for scaling
    final weights = sortedEntries.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    final padding = weightRange * 0.1; // 10% padding

    final adjustedMin = minWeight - padding;
    final adjustedMax = maxWeight + padding;
    final adjustedRange = adjustedMax - adjustedMin;

    // Create paint objects
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final x = size.width * i / (sortedEntries.length - 1);
      final normalizedWeight = (entry.weight - adjustedMin) / adjustedRange;
      final y = size.height * (1 - normalizedWeight);
      points.add(Offset(x, y));
    }

    // Draw line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
