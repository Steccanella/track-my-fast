import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum Mood { excellent, good, okay, bad, terrible }

class DailyEntry {
  final String id;
  final DateTime date;
  final String? notes;
  final Mood? mood;
  final double? waterIntake; // in ml
  final double? weight;
  final String? weightUnit; // 'kg' or 'lbs'

  static const Uuid _uuid = Uuid();

  DailyEntry({
    String? id,
    required this.date,
    this.notes,
    this.mood,
    this.waterIntake,
    this.weight,
    this.weightUnit,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'notes': notes,
      'mood': mood?.name,
      'waterIntake': waterIntake,
      'weight': weight,
      'weightUnit': weightUnit,
    };
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      mood: json['mood'] != null
          ? Mood.values.firstWhere((m) => m.name == json['mood'])
          : null,
      waterIntake: json['waterIntake']?.toDouble(),
      weight: json['weight']?.toDouble(),
      weightUnit: json['weightUnit'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'mood': mood?.name,
      'waterIntake': waterIntake,
      'weight': weight,
      'weightUnit': weightUnit,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory DailyEntry.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return DailyEntry(
      id: documentId,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      mood: data['mood'] != null
          ? Mood.values.firstWhere((m) => m.name == data['mood'])
          : null,
      waterIntake: data['waterIntake']?.toDouble(),
      weight: data['weight']?.toDouble(),
      weightUnit: data['weightUnit'],
    );
  }

  DailyEntry copyWith({
    String? id,
    DateTime? date,
    String? notes,
    Mood? mood,
    double? waterIntake,
    double? weight,
    String? weightUnit,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      mood: mood ?? this.mood,
      waterIntake: waterIntake ?? this.waterIntake,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  String get moodEmoji {
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
      case null:
        return '❓';
    }
  }

  String get moodName {
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
      case null:
        return 'Not set';
    }
  }
}
