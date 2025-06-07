import 'package:flutter/material.dart';

class FastingType {
  final String name;
  final Duration fastingDuration;
  final Duration eatingDuration;
  final String description;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String difficulty;
  final bool isCustom;

  const FastingType({
    required this.name,
    required this.fastingDuration,
    required this.eatingDuration,
    required this.description,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.difficulty,
    this.isCustom = false,
  });

  static const List<FastingType> presetTypes = [
    FastingType(
      name: '16:8',
      fastingDuration: Duration(hours: 16),
      eatingDuration: Duration(hours: 8),
      description: '16 hours of fasting, 8 hours eating window',
      subtitle: 'Perfect for beginners',
      color: Color(0xFF4CAF50),
      icon: Icons.access_time,
      difficulty: 'Beginner',
    ),
    FastingType(
      name: '18:6',
      fastingDuration: Duration(hours: 18),
      eatingDuration: Duration(hours: 6),
      description: '18 hours of fasting, 6 hours eating window',
      subtitle: 'Intermediate fasting',
      color: Color(0xFF2196F3),
      icon: Icons.schedule,
      difficulty: 'Intermediate',
    ),
    FastingType(
      name: '20:4',
      fastingDuration: Duration(hours: 20),
      eatingDuration: Duration(hours: 4),
      description: '20 hours of fasting, 4 hours eating window',
      subtitle: 'Warrior diet protocol',
      color: Color(0xFFFF9800),
      icon: Icons.fitness_center,
      difficulty: 'Advanced',
    ),
    FastingType(
      name: '24:0',
      fastingDuration: Duration(hours: 24),
      eatingDuration: Duration(hours: 0),
      description: '24 hours fasting',
      subtitle: 'One meal a day (OMAD)',
      color: Color(0xFFE91E63),
      icon: Icons.restaurant,
      difficulty: 'Expert',
    ),
    FastingType(
      name: 'Custom',
      fastingDuration: Duration(hours: 1),
      eatingDuration: Duration(hours: 0),
      description: 'Set your own timer',
      subtitle: 'Flexible fasting',
      color: Color(0xFF9C27B0),
      icon: Icons.tune,
      difficulty: 'All Levels',
      isCustom: true,
    ),
  ];
}
