import 'package:cloud_firestore/cloud_firestore.dart';

class FastingSession {
  final String? id;
  final DateTime startTime;
  final DateTime? endTime;
  final String fastingTypeName;
  final Duration targetDuration;
  final bool completed;

  FastingSession({
    this.id,
    required this.startTime,
    this.endTime,
    required this.fastingTypeName,
    required this.targetDuration,
    this.completed = false,
  });

  Duration get actualDuration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  double get progressPercentage {
    return (actualDuration.inMinutes / targetDuration.inMinutes).clamp(
      0.0,
      1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'fastingTypeName': fastingTypeName,
      'targetDuration': targetDuration.inMinutes,
      'completed': completed,
    };
  }

  factory FastingSession.fromJson(Map<String, dynamic> json) {
    return FastingSession(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      fastingTypeName: json['fastingTypeName'],
      targetDuration: Duration(minutes: json['targetDuration']),
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'fastingTypeName': fastingTypeName,
      'targetDuration': targetDuration.inMinutes,
      'completed': completed,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory FastingSession.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return FastingSession(
      id: documentId,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      fastingTypeName: data['fastingTypeName'] ?? '',
      targetDuration: Duration(minutes: data['targetDuration'] ?? 0),
      completed: data['completed'] ?? false,
    );
  }

  FastingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? fastingTypeName,
    Duration? targetDuration,
    bool? completed,
  }) {
    return FastingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      fastingTypeName: fastingTypeName ?? this.fastingTypeName,
      targetDuration: targetDuration ?? this.targetDuration,
      completed: completed ?? this.completed,
    );
  }
}
