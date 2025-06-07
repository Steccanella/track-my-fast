import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fasting_provider.dart';
import '../models/weight_entry.dart';

class WeightTracker extends StatelessWidget {
  const WeightTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FastingProvider>(
      builder: (context, fastingProvider, child) {
        final latestWeight = fastingProvider.latestWeightEntry;

        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_weight,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latestWeight != null
                          ? latestWeight.weightWithUnit
                          : 'Tap to log weight',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showWeightDialog(context, fastingProvider),
                icon: const Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeightDialog(BuildContext context, FastingProvider provider) {
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    WeightUnit selectedUnit = WeightUnit.kg;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (${selectedUnit.name})',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<WeightUnit>(
                    value: selectedUnit,
                    items: WeightUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (unit) {
                      if (unit != null) {
                        setState(() {
                          selectedUnit = unit;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final weightText = weightController.text.trim();
                if (weightText.isNotEmpty) {
                  final weight = double.tryParse(weightText);
                  if (weight != null && weight > 0) {
                    final entry = WeightEntry(
                      date: DateTime.now(),
                      weight: weight,
                      unit: selectedUnit,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );
                    provider.addWeightEntry(entry);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid weight'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
