import 'package:flutter/material.dart';

class PlanSummaryCard extends StatelessWidget {
  final String date;
  final double targetCost;
  final double totalCost;
  final List<String> items;

  const PlanSummaryCard({
    super.key,
    required this.date,
    required this.targetCost,
    required this.totalCost,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan for $date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Target Cost: \$${targetCost.toStringAsFixed(2)}'),
            Text('Selected Total: \$${totalCost.toStringAsFixed(2)}'),
            const Divider(height: 24),
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...items.map(
              (name) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $name'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
