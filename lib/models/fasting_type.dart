class FastingType {
  final String name;
  final Duration fastingDuration;
  final Duration eatingDuration;
  final String description;

  const FastingType({
    required this.name,
    required this.fastingDuration,
    required this.eatingDuration,
    required this.description,
  });

  static const List<FastingType> presetTypes = [
    FastingType(
      name: '16:8',
      fastingDuration: Duration(hours: 16),
      eatingDuration: Duration(hours: 8),
      description: '16 hours of fasting, 8 hours eating window',
    ),
    FastingType(
      name: '18:6',
      fastingDuration: Duration(hours: 18),
      eatingDuration: Duration(hours: 6),
      description: '18 hours of fasting, 6 hours eating window',
    ),
    FastingType(
      name: '20:4',
      fastingDuration: Duration(hours: 20),
      eatingDuration: Duration(hours: 4),
      description: '20 hours of fasting, 4 hours eating window',
    ),
    FastingType(
      name: '24:0',
      fastingDuration: Duration(hours: 24),
      eatingDuration: Duration(hours: 0),
      description: '24 hours fasting',
    ),
  ];
}
