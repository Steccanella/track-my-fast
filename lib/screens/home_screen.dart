import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/fasting_provider.dart';

import 'package:intl/intl.dart';
import 'history_screen.dart';
import 'fasting_options_screen.dart';

import 'main_navigation.dart';
import '../widgets/weight_tracker.dart';
import '../widgets/fasting_zones_timer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildCurrentZoneIndicator(Duration elapsedTime) {
    final hours = elapsedTime.inHours;
    String zoneName;
    String emoji;
    Color color;

    if (hours < 4) {
      zoneName = 'Anabolic';
      emoji = '🍽️';
      color = const Color(0xFFFFD93D);
    } else if (hours < 16) {
      zoneName = 'Catabolic';
      emoji = '💪';
      color = const Color(0xFFFF6B6B);
    } else if (hours < 24) {
      zoneName = 'Fat Burning';
      emoji = '🔥';
      color = const Color(0xFF4ECDC4);
    } else {
      zoneName = 'Ketosis';
      emoji = '⚡';
      color = const Color(0xFF45B7D1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            zoneName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneInfoCard(Duration elapsedTime) {
    final hours = elapsedTime.inHours;
    String zoneName;
    String description;
    String benefits;
    Color color;

    if (hours < 4) {
      zoneName = 'Anabolic Phase';
      description =
          'Your body is still digesting food and blood sugar levels are settling.';
      benefits =
          '• Food digestion\n• Blood sugar stabilization\n• Initial metabolic transition';
      color = const Color(0xFFFFD93D);
    } else if (hours < 16) {
      zoneName = 'Catabolic Phase';
      description =
          'Your body starts breaking down stored energy and switching to fat burning.';
      benefits =
          '• Glycogen depletion\n• Fat mobilization begins\n• Improved insulin sensitivity';
      color = const Color(0xFFFF6B6B);
    } else if (hours < 24) {
      zoneName = 'Fat Burning Phase';
      description =
          'Your body is now primarily burning fat for energy. This is where the magic happens!';
      benefits =
          '• Peak fat oxidation\n• Increased energy levels\n• Mental clarity improvement';
      color = const Color(0xFF4ECDC4);
    } else {
      zoneName = 'Ketosis Phase';
      description =
          'Your liver produces ketones, providing sustained energy and powerful health benefits.';
      benefits =
          '• Ketone production\n• Enhanced brain function\n• Cellular repair activation';
      color = const Color(0xFF45B7D1);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.science,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  zoneName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What\'s happening:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            benefits,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStageCard(Duration elapsedTime) {
    final hours = elapsedTime.inHours;
    String zoneName;
    String description;
    String emoji;
    Color color;
    String timeRange;

    if (hours < 4) {
      zoneName = 'Anabolic Phase';
      description =
          'Your body is digesting food and stabilizing blood sugar levels.';
      emoji = '🍽️';
      color = const Color(0xFFFFD93D);
      timeRange = '0-4 hours';
    } else if (hours < 16) {
      zoneName = 'Catabolic Phase';
      description =
          'Your body is breaking down stored energy and switching to fat burning.';
      emoji = '💪';
      color = const Color(0xFFFF6B6B);
      timeRange = '4-16 hours';
    } else if (hours < 24) {
      zoneName = 'Fat Burning Phase';
      description =
          'Your body is primarily burning fat for energy. Peak fat oxidation!';
      emoji = '🔥';
      color = const Color(0xFF4ECDC4);
      timeRange = '16-24 hours';
    } else {
      zoneName = 'Ketosis Phase';
      description =
          'Your liver is producing ketones for sustained energy and brain function.';
      emoji = '⚡';
      color = const Color(0xFF45B7D1);
      timeRange = '24+ hours';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zoneName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeRange,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showZoneInfoDialog(BuildContext context, Duration elapsedTime) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fasting Science',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Zone info card content
              _buildZoneInfoCard(elapsedTime),

              const SizedBox(height: 20),

              // Educational note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your body transitions through different metabolic phases during fasting, each offering unique benefits.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FastingProvider>(
      builder: (context, fastingProvider, child) {
        final currentSession = fastingProvider.currentSession;
        final selectedType = fastingProvider.selectedType;
        final isActive = currentSession != null;
        final progress = fastingProvider.progressPercentage;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                // Header with controls only
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fasting Type with info button
                      Row(
                        children: [
                          Text(
                            selectedType.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isActive)
                            GestureDetector(
                              onTap: () => _showZoneInfoDialog(
                                  context, fastingProvider.elapsedTime),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              fastingProvider.notificationsEnabled
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                            ),
                            onPressed: () {
                              fastingProvider.setNotificationsEnabled(
                                !fastingProvider.notificationsEnabled,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Enhanced Fasting Zones Timer
                Expanded(
                  child: Center(
                    child: FastingZonesTimer(
                      progress: progress,
                      elapsedTime: fastingProvider.elapsedTime,
                      remainingTime: fastingProvider.remainingTime,
                      targetDuration: selectedType.fastingDuration,
                      isActive: isActive,
                      isOvertime: fastingProvider.isOvertime,
                      centerContent: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isActive) ...[
                            // Current zone indicator
                            _buildCurrentZoneIndicator(
                                fastingProvider.elapsedTime),
                            const SizedBox(height: 12),
                            Text(
                              'Elapsed (${(progress * 100).round()}%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(fastingProvider.elapsedTime),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B6B),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              fastingProvider.isOvertime
                                  ? 'Overtime!'
                                  : 'Target: ${_formatDuration(selectedType.fastingDuration)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: fastingProvider.isOvertime
                                    ? const Color(0xFFFF6B6B)
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (fastingProvider.isOvertime) ...[
                              const SizedBox(height: 2),
                              Text(
                                '+${_formatDuration(fastingProvider.overtimeAmount)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selectedType.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                selectedType.icon,
                                color: selectedType.color,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              selectedType.name,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ready to start',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedType.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Current Stage Info Card (only show when active)
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildCurrentStageCard(fastingProvider.elapsedTime),
                  ),

                const SizedBox(height: 20),

                // Action Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isActive) {
                          fastingProvider.stopFasting(completed: false);
                        } else {
                          fastingProvider.startFasting();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        isActive ? 'End fast early' : 'Start Fast',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Fast timing info (only show when active)
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 20.0, left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              'STARTED FASTING',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  DateFormat('EEEE, h:mm a')
                                      .format(currentSession.startTime),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'FAST ENDING',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, h:mm a').format(
                                currentSession.startTime
                                    .add(selectedType.fastingDuration),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Weight Tracker (only show when not active)
                if (!isActive) const WeightTracker(),

                // Fasting Type Selector (only show when not active)
                if (!isActive)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 20.0, left: 20.0, right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FastingOptionsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: selectedType.color.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: selectedType.color.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selectedType.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                selectedType.icon,
                                color: selectedType.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        selectedType.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedType.color
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          selectedType.difficulty,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: selectedType.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedType.subtitle,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
