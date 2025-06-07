class WeightEntry {
  final DateTime date;
  final double weight;
  final String? notes;
  final String? id;

  const WeightEntry({
    required this.date,
    required this.weight,
    this.notes,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json, [String? id]) {
    return WeightEntry(
      date: DateTime.parse(json['date']),
      weight: json['weight'].toDouble(),
      notes: json['notes'],
      id: id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'weight': weight,
      'notes': notes,
    };
  }

  factory WeightEntry.fromFirestore(Map<String, dynamic> data, String id) {
    return WeightEntry(
      date: (data['date'] as DateTime),
      weight: data['weight'].toDouble(),
      notes: data['notes'],
      id: id,
    );
  }

  WeightEntry copyWith({
    DateTime? date,
    double? weight,
    String? notes,
    String? id,
  }) {
    return WeightEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }
}
