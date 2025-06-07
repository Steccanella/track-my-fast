enum WeightUnit { kg, lbs }

class WeightEntry {
  final DateTime date;
  final double weight;
  final WeightUnit unit;
  final String? notes;
  final String? id;

  const WeightEntry({
    required this.date,
    required this.weight,
    this.unit = WeightUnit.kg,
    this.notes,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'unit': unit.name,
      'notes': notes,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json, [String? id]) {
    return WeightEntry(
      date: DateTime.parse(json['date']),
      weight: json['weight'].toDouble(),
      unit: WeightUnit.values.firstWhere(
        (u) => u.name == json['unit'],
        orElse: () => WeightUnit.kg,
      ),
      notes: json['notes'],
      id: id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'weight': weight,
      'unit': unit.name,
      'notes': notes,
    };
  }

  factory WeightEntry.fromFirestore(Map<String, dynamic> data, String id) {
    return WeightEntry(
      date: (data['date'] as DateTime),
      weight: data['weight'].toDouble(),
      unit: WeightUnit.values.firstWhere(
        (u) => u.name == data['unit'],
        orElse: () => WeightUnit.kg,
      ),
      notes: data['notes'],
      id: id,
    );
  }

  WeightEntry copyWith({
    DateTime? date,
    double? weight,
    WeightUnit? unit,
    String? notes,
    String? id,
  }) {
    return WeightEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }

  String get weightWithUnit {
    return '${weight.toStringAsFixed(1)} ${unit.name}';
  }
}
