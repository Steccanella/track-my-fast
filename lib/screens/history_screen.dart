import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fasting_provider.dart';
import '../widgets/github_style_chart.dart';
import '../widgets/weight_chart.dart';
import '../models/fasting_session.dart';
import '../models/daily_entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Analytics'),
                Tab(text: 'History'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildAnalyticsTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<FastingProvider>(
      builder: (context, fastingProvider, child) {
        final history = fastingProvider.history;
        final completedSessions = history.where((s) => s.completed).length;
        final totalSessions = history.length;
        final successRate =
            totalSessions > 0 ? (completedSessions / totalSessions) : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Fasts',
                      '$totalSessions',
                      Icons.timer,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Success Rate',
                      '${(successRate * 100).round()}%',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Current Streak',
                      '7 days',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Longest Fast',
                      '24h 15m',
                      Icons.emoji_events,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Weekly Progress
              _buildWeeklyProgress(),

              const SizedBox(height: 32),

              // Achievements
              _buildAchievements(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsChart(),
          const SizedBox(height: 24),
          _buildWeightProgress(),
          const SizedBox(height: 24),
          _buildTrends(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<FastingProvider>(
      builder: (context, fastingProvider, child) {
        final history = fastingProvider.history;
        final dailyEntries = fastingProvider.dailyEntries;

        // Group entries by date
        final Map<DateTime, List<dynamic>> groupedEntries = {};

        // Add fasting sessions
        for (final session in history) {
          final date = DateTime(session.startTime.year, session.startTime.month,
              session.startTime.day);
          groupedEntries.putIfAbsent(date, () => []).add(session);
        }

        // Add daily entries
        for (final entry in dailyEntries) {
          final date =
              DateTime(entry.date.year, entry.date.month, entry.date.day);
          groupedEntries.putIfAbsent(date, () => []).add(entry);
        }

        if (groupedEntries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No history yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start tracking to see your progress here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort dates in reverse order (most recent first)
        final sortedDates = groupedEntries.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final entries = groupedEntries[date]!;

            // Find the daily entry for this date
            final dailyEntry = entries.firstWhere(
              (entry) => entry is DailyEntry,
              orElse: () => null,
            ) as DailyEntry?;

            // Find fasting sessions for this date
            final sessions = entries.whereType<FastingSession>().toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Fasting sessions for this date
                ...sessions.map((session) => _buildFastingSessionCard(
                    session, fastingProvider, dailyEntry)),

                // Daily entry card if exists and no fasting sessions
                if (dailyEntry != null && sessions.isEmpty)
                  _buildDailyEntryCard(dailyEntry, fastingProvider),

                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFastingSessionCard(FastingSession session,
      FastingProvider provider, DailyEntry? dailyEntry) {
    final duration = session.actualDuration;
    final completed = session.completed;
    final hasTrackingData = dailyEntry != null &&
        (dailyEntry.notes?.isNotEmpty == true ||
            dailyEntry.mood != null ||
            dailyEntry.waterIntake != null ||
            dailyEntry.weight != null);

    return GestureDetector(
      onTap: hasTrackingData
          ? () => _showDayDetailsDialog(context, session, dailyEntry)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: hasTrackingData
              ? Border.all(color: Colors.blue.withOpacity(0.3))
              : null,
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    completed ? Icons.check_circle : Icons.access_time,
                    color: completed ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.fastingTypeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Fasting Session',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasTrackingData)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.blue, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Tap for details',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    completed ? 'Completed' : 'Partial',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: completed ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditSessionDialog(context, session, provider);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, session, provider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHistoryDetail(
                    'Duration',
                    duration != null
                        ? '${duration.inHours}h ${duration.inMinutes.remainder(60)}m'
                        : 'N/A',
                    Icons.timer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHistoryDetail(
                    'Start Time',
                    DateFormat('HH:mm').format(session.startTime),
                    Icons.play_arrow,
                  ),
                ),
                if (session.endTime != null)
                  Expanded(
                    child: _buildHistoryDetail(
                      'End Time',
                      DateFormat('HH:mm').format(session.endTime!),
                      Icons.stop,
                    ),
                  ),
              ],
            ),

            // Quick preview of daily tracking data
            if (hasTrackingData) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (dailyEntry!.mood != null)
                    _buildQuickStat(dailyEntry.moodEmoji, dailyEntry.moodName,
                        Colors.orange),
                  if (dailyEntry.waterIntake != null)
                    _buildQuickStat('💧',
                        '${dailyEntry.waterIntake!.toInt()}ml', Colors.cyan),
                  if (dailyEntry.weight != null)
                    _buildQuickStat(
                        '⚖️',
                        '${dailyEntry.weight!.toStringAsFixed(1)}${dailyEntry.weightUnit ?? 'kg'}',
                        Colors.green),
                  if (dailyEntry.notes?.isNotEmpty == true)
                    _buildQuickStat('📝', 'Notes added', Colors.blue),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyEntryCard(DailyEntry entry, FastingProvider provider) {
    return GestureDetector(
      onTap: () => _showDayDetailsDialog(context, null, entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.today,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Tap to view details',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show entry details preview
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (entry.mood != null)
                  _buildQuickStat(
                      entry.moodEmoji, entry.moodName, Colors.orange),
                if (entry.waterIntake != null)
                  _buildQuickStat(
                      '💧', '${entry.waterIntake!.toInt()}ml', Colors.cyan),
                if (entry.weight != null)
                  _buildQuickStat(
                      '⚖️',
                      '${entry.weight!.toStringAsFixed(1)}${entry.weightUnit ?? 'kg'}',
                      Colors.green),
                if (entry.notes?.isNotEmpty == true)
                  _buildQuickStat('📝', 'Notes added', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
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
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              final isCompleted = index < 5; // Mock data

              return Column(
                children: [
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {
        'title': 'First Fast',
        'subtitle': 'Complete your first fast',
        'achieved': true
      },
      {'title': 'Week Warrior', 'subtitle': '7 day streak', 'achieved': true},
      {'title': 'Dedication', 'subtitle': '30 day streak', 'achieved': false},
      {
        'title': 'Master Faster',
        'subtitle': '100 total fasts',
        'achieved': false
      },
    ];

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
            'Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...achievements.map((achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: achievement['achieved'] as bool
                            ? Colors.yellow.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: achievement['achieved'] as bool
                            ? Colors.yellow[700]
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            achievement['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAnalyticsChart() {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Pattern',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          GitHubStyleChart(),
        ],
      ),
    );
  }

  Widget _buildWeightProgress() {
    return Consumer<FastingProvider>(
      builder: (context, fastingProvider, child) {
        final weightEntries = fastingProvider.weightEntries;

        if (weightEntries.length < 3) {
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
              children: [
                const Text(
                  'Weight Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add more weight entries to see your progress chart',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

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
                'Weight Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              WeightChart(entries: fastingProvider.weightEntries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrends() {
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
            'Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildTrendItem('Average Fast Duration', '16.5 hours',
              Icons.timer_outlined, Colors.blue),
          const SizedBox(height: 12),
          _buildTrendItem('Completion Rate', '87%', Icons.check_circle_outline,
              Colors.green),
          const SizedBox(height: 12),
          _buildTrendItem('Current Streak', '7 days',
              Icons.local_fire_department_outlined, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryDetail(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showEditSessionDialog(
      BuildContext context, FastingSession session, FastingProvider provider) {
    final TextEditingController startController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm').format(session.startTime),
    );
    final TextEditingController endController = TextEditingController(
      text: session.endTime != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(session.endTime!)
          : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Fasting Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startController,
                decoration: const InputDecoration(
                  labelText: 'Start Time (yyyy-MM-dd HH:mm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endController,
                decoration: const InputDecoration(
                  labelText: 'End Time (yyyy-MM-dd HH:mm)',
                  border: OutlineInputBorder(),
                ),
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
                try {
                  final newStartTime = DateFormat('yyyy-MM-dd HH:mm')
                      .parse(startController.text);
                  DateTime? newEndTime;
                  if (endController.text.isNotEmpty) {
                    newEndTime = DateFormat('yyyy-MM-dd HH:mm')
                        .parse(endController.text);
                  }

                  final updatedSession = session.copyWith(
                    startTime: newStartTime,
                    endTime: newEndTime,
                  );

                  provider.updateFastingSession(updatedSession);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid date format')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, FastingSession session, FastingProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Fasting Session'),
          content: const Text(
              'Are you sure you want to delete this fasting session? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteFastingSession(session.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDayDetailsDialog(
      BuildContext context, FastingSession? session, DailyEntry? dailyEntry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    session != null ? Icons.timer : Icons.today,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session != null
                              ? DateFormat('EEEE, MMMM dd, yyyy')
                                  .format(session.startTime)
                              : DateFormat('EEEE, MMMM dd, yyyy')
                                  .format(dailyEntry!.date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Daily Tracking Details',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Fasting Session Info (if exists)
              if (session != null) ...[
                _buildDetailSection(
                  'Fasting Session',
                  Icons.timer,
                  Colors.green,
                  [
                    _buildDetailRow('Type', session.fastingTypeName),
                    _buildDetailRow(
                        'Duration',
                        session.actualDuration != null
                            ? '${session.actualDuration!.inHours}h ${session.actualDuration!.inMinutes.remainder(60)}m'
                            : 'N/A'),
                    _buildDetailRow(
                        'Status', session.completed ? 'Completed' : 'Partial'),
                    if (session.endTime != null)
                      _buildDetailRow('Time',
                          '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime!)}'),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Daily Entry Info (if exists)
              if (dailyEntry != null) ...[
                // Mood
                if (dailyEntry.mood != null)
                  _buildDetailSection(
                    'Mood',
                    Icons.sentiment_satisfied,
                    Colors.orange,
                    [
                      Row(
                        children: [
                          Text(
                            dailyEntry.moodEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            dailyEntry.moodName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                // Water Intake
                if (dailyEntry.waterIntake != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Water Intake',
                    Icons.water_drop,
                    Colors.cyan,
                    [
                      Row(
                        children: [
                          const Text('💧', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text(
                            '${dailyEntry.waterIntake!.toInt()} ml',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],

                // Weight
                if (dailyEntry.weight != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Weight',
                    Icons.monitor_weight,
                    Colors.green,
                    [
                      Row(
                        children: [
                          const Text('⚖️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text(
                            '${dailyEntry.weight!.toStringAsFixed(1)} ${dailyEntry.weightUnit ?? 'kg'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],

                // Notes
                if (dailyEntry.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Notes',
                    Icons.note,
                    Colors.blue,
                    [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          dailyEntry.notes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              // No tracking data message
              if (dailyEntry == null ||
                  (dailyEntry.notes?.isEmpty != false &&
                      dailyEntry.mood == null &&
                      dailyEntry.waterIntake == null &&
                      dailyEntry.weight == null)) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.sentiment_neutral,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No daily tracking data for this day',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
