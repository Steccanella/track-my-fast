import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fasting_provider.dart';

import '../models/daily_entry.dart';
import 'fasting_options_screen.dart';

class FastsScreen extends StatelessWidget {
  const FastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<FastingProvider>(
          builder: (context, fastingProvider, child) {
            final today = DateTime.now();
            final todayEntry = fastingProvider.todaysDailyEntry;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Tracker',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM dd').format(today),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Daily Tracking Cards
                  _buildTrackingCard(
                    'Notes',
                    Icons.note_alt,
                    Colors.blue,
                    todayEntry?.notes ?? 'Add a note about your day',
                    () =>
                        _showNotesDialog(context, fastingProvider, todayEntry),
                  ),

                  const SizedBox(height: 16),

                  _buildTrackingCard(
                    'Mood',
                    Icons.mood,
                    Colors.orange,
                    '${todayEntry?.moodEmoji ?? '❓'} ${todayEntry?.moodName ?? 'How are you feeling?'}',
                    () => _showMoodDialog(context, fastingProvider, todayEntry),
                  ),

                  const SizedBox(height: 16),

                  _buildTrackingCard(
                    'Water Intake',
                    Icons.local_drink,
                    Colors.cyan,
                    todayEntry?.waterIntake != null
                        ? '${todayEntry!.waterIntake!.toInt()} ml'
                        : 'Track your hydration',
                    () =>
                        _showWaterDialog(context, fastingProvider, todayEntry),
                  ),

                  const SizedBox(height: 16),

                  _buildTrackingCard(
                    'Weight',
                    Icons.monitor_weight,
                    Colors.green,
                    todayEntry?.weight != null
                        ? '${todayEntry!.weight!.toStringAsFixed(1)} ${todayEntry.weightUnit ?? 'kg'}'
                        : 'Log your weight',
                    () =>
                        _showWeightDialog(context, fastingProvider, todayEntry),
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions for Fasting
                  const Text(
                    'Fasting Control',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, fastingProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrackingCard(String title, IconData icon, Color color,
      String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, FastingProvider fastingProvider) {
    final isActive = fastingProvider.currentSession != null;

    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: isActive ? 'End Fast' : 'Start Fast',
            subtitle: isActive ? 'End your fast' : 'Start your fast',
            icon: isActive ? Icons.stop_circle : Icons.play_circle,
            color: isActive ? Colors.red : Colors.green,
            onTap: () {
              if (isActive) {
                fastingProvider.stopFasting(completed: false);
              } else {
                fastingProvider.startFasting();
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: 'Change Plan',
            subtitle: 'Switch fasting protocol',
            icon: Icons.tune,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FastingOptionsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, FastingProvider provider,
      DailyEntry? currentEntry) {
    final TextEditingController controller =
        TextEditingController(text: currentEntry?.notes ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daily Notes'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'How was your day? Any thoughts about your fasting experience?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveDailyEntry(provider, currentEntry,
                    notes: controller.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showMoodDialog(BuildContext context, FastingProvider provider,
      DailyEntry? currentEntry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How are you feeling?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: Mood.values.map((mood) {
              return ListTile(
                leading: Text(
                  _getMoodEmoji(mood),
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(_getMoodName(mood)),
                onTap: () {
                  _saveDailyEntry(provider, currentEntry, mood: mood);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showWaterDialog(BuildContext context, FastingProvider provider,
      DailyEntry? currentEntry) {
    final TextEditingController controller = TextEditingController(
      text: currentEntry?.waterIntake?.toInt().toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Water Intake'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter amount in ml',
              suffixText: 'ml',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final waterAmount = double.tryParse(controller.text);
                _saveDailyEntry(provider, currentEntry,
                    waterIntake: waterAmount);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showWeightDialog(BuildContext context, FastingProvider provider,
      DailyEntry? currentEntry) {
    final TextEditingController weightController = TextEditingController(
      text: currentEntry?.weight?.toString() ?? '',
    );
    String selectedUnit = currentEntry?.weightUnit ?? 'kg';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Weight'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter your weight',
                      suffixText: selectedUnit,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Unit: '),
                      DropdownButton<String>(
                        value: selectedUnit,
                        items: ['kg', 'lbs'].map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final weight = double.tryParse(weightController.text);
                    _saveDailyEntry(provider, currentEntry,
                        weight: weight, weightUnit: selectedUnit);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveDailyEntry(
    FastingProvider provider,
    DailyEntry? currentEntry, {
    String? notes,
    Mood? mood,
    double? waterIntake,
    double? weight,
    String? weightUnit,
  }) {
    final today = DateTime.now();
    final entry = currentEntry?.copyWith(
          notes: notes ?? currentEntry.notes,
          mood: mood ?? currentEntry.mood,
          waterIntake: waterIntake ?? currentEntry.waterIntake,
          weight: weight ?? currentEntry.weight,
          weightUnit: weightUnit ?? currentEntry.weightUnit,
        ) ??
        DailyEntry(
          date: today,
          notes: notes,
          mood: mood,
          waterIntake: waterIntake,
          weight: weight,
          weightUnit: weightUnit,
        );

    provider.saveDailyEntry(entry);
  }

  String _getMoodEmoji(Mood mood) {
    switch (mood) {
      case Mood.excellent:
        return '😄';
      case Mood.good:
        return '😊';
      case Mood.okay:
        return '😐';
      case Mood.bad:
        return '😞';
      case Mood.terrible:
        return '😢';
    }
  }

  String _getMoodName(Mood mood) {
    switch (mood) {
      case Mood.excellent:
        return 'Excellent';
      case Mood.good:
        return 'Good';
      case Mood.okay:
        return 'Okay';
      case Mood.bad:
        return 'Bad';
      case Mood.terrible:
        return 'Terrible';
    }
  }
}
