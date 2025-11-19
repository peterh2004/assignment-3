import 'package:flutter/material.dart';

class FoodItemTile extends StatelessWidget {
  final String title;
  final double cost;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FoodItemTile({
    super.key,
    required this.title,
    required this.cost,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('\$${cost.toStringAsFixed(2)}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
