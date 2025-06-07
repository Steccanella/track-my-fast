import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fasting_provider.dart';
import '../models/fasting_session.dart';

class GitHubStyleChart extends StatelessWidget {
  const GitHubStyleChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FastingProvider>(
      builder: (context, fastingProvider, child) {
        final weekData = _getWeekData(fastingProvider.history);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Fasting Pattern',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildChart(weekData),
              const SizedBox(height: 16),
              _buildLegend(),
            ],
          ),
        );
      },
    );
  }

  List<DayData> _getWeekData(List<FastingSession> history) {
    final now = DateTime.now();
    final weekData = <DayData>[];

    // Get the last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Find sessions that overlap with this day
      double fastingHours = 0;
      for (final session in history) {
        if (session.endTime != null) {
          final sessionStart = session.startTime.isAfter(dayStart)
              ? session.startTime
              : dayStart;
          final sessionEnd =
              session.endTime!.isBefore(dayEnd) ? session.endTime! : dayEnd;

          if (sessionStart.isBefore(dayEnd) && sessionEnd.isAfter(dayStart)) {
            // Calculate overlap
            final overlapDuration = sessionEnd.difference(sessionStart);
            if (overlapDuration.isNegative == false) {
              fastingHours += overlapDuration.inMinutes / 60.0;
            }
          }
        }
      }

      // Cap at 24 hours
      fastingHours = fastingHours > 24 ? 24 : fastingHours;
      final eatingHours = 24 - fastingHours;

      weekData.add(DayData(
        date: date,
        fastingHours: fastingHours,
        eatingHours: eatingHours,
      ));
    }

    return weekData;
  }

  Widget _buildChart(List<DayData> weekData) {
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weekData.map((dayData) => _buildDayColumn(dayData)).toList(),
      ),
    );
  }

  Widget _buildDayColumn(DayData dayData) {
    final totalHeight = 90.0; // Reduced from 100 to give more space
    final fastingHeight = (dayData.fastingHours / 24) * totalHeight;
    final eatingHeight = (dayData.eatingHours / 24) * totalHeight;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Fasting hours (top part)
            if (fastingHeight > 0)
              Container(
                height: fastingHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            // Eating hours (bottom part)
            if (eatingHeight > 0)
              Container(
                height: eatingHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            const SizedBox(height: 6), // Reduced spacing
            // Day label
            Text(
              _getDayLabel(dayData.date),
              style: TextStyle(
                fontSize: 9, // Slightly smaller font
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(const Color(0xFFFF6B6B), 'Fasting'),
        const SizedBox(width: 24),
        _buildLegendItem(const Color(0xFF4CAF50), 'Eating'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getDayLabel(DateTime date) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[date.weekday % 7];
  }
}

class DayData {
  final DateTime date;
  final double fastingHours;
  final double eatingHours;

  DayData({
    required this.date,
    required this.fastingHours,
    required this.eatingHours,
  });
}
