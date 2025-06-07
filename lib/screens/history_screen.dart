import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fasting_provider.dart';
import '../models/fasting_session.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasting History'),
      ),
      body: Consumer<FastingProvider>(
        builder: (context, fastingProvider, child) {
          final history = fastingProvider.history;

          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No fasting history yet.\nStart your first fast!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final session = history[history.length - 1 - index];
              final completed = session.completed;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: Icon(
                    completed ? Icons.check_circle : Icons.cancel,
                    color: completed ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  title: Text(
                    session.fastingTypeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Started: ${DateFormat('MMM d, h:mm a').format(session.startTime)}',
                      ),
                      if (session.endTime != null)
                        Text(
                          'Duration: ${_formatDuration(session.actualDuration)}',
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${(session.progressPercentage * 100).round()}%',
                    style: TextStyle(
                      color: completed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
