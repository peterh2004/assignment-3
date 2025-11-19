import 'dart:convert';

import 'food_item.dart';

class OrderPlan {
  final int? id;
  final String date;
  final double targetCost;
  final List<FoodItem> selectedItems;

  const OrderPlan({
    this.id,
    required this.date,
    required this.targetCost,
    required this.selectedItems,
  });

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    final itemsJson = map['selected_items'] as String? ?? '[]';
    final decoded = jsonDecode(itemsJson) as List<dynamic>;
    final items = decoded
        .map((e) => FoodItem.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
    return OrderPlan(
      id: map['id'] as int?,
      date: map['date'] as String,
      targetCost: (map['target_cost'] as num).toDouble(),
      selectedItems: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'target_cost': targetCost,
      'selected_items': jsonEncode(
        selectedItems.map((item) => item.toMap()).toList(),
      ),
    };
  }
}
