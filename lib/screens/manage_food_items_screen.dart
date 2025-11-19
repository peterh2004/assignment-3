import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/database_service.dart';
import '../widgets/food_item_tile.dart';

class ManageFoodItemsScreen extends StatefulWidget {
  const ManageFoodItemsScreen({super.key});

  static const routeName = '/manage-food-items';

  @override
  State<ManageFoodItemsScreen> createState() => _ManageFoodItemsScreenState();
}

class _ManageFoodItemsScreenState extends State<ManageFoodItemsScreen> {
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final items = await DatabaseService.instance.getFoodItems();
    setState(() {
      _foodItems = items;
      _isLoading = false;
    });
  }

  Future<void> _showItemDialog({FoodItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final costController =
        TextEditingController(text: item != null ? item.cost.toStringAsFixed(2) : '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Food Item' : 'Edit Food Item'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Enter a name' : null,
                ),
                TextFormField(
                  controller: costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Cost'),
                  validator: (value) {
                    final cost = double.tryParse(value ?? '');
                    if (cost == null || cost <= 0) {
                      return 'Enter a valid cost';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final name = nameController.text.trim();
      final cost = double.parse(costController.text.trim());
      if (item == null) {
        await DatabaseService.instance.addFoodItem(name, cost);
      } else {
        await DatabaseService.instance.updateFoodItem(item.id!, name, cost);
      }
      await _refresh();
    }
  }

  Future<void> _deleteItem(FoodItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Item'),
        content: Text('Delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteFoodItem(item.id!);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Items'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final item = _foodItems[index];
                  return FoodItemTile(
                    title: item.name,
                    cost: item.cost,
                    onEdit: () => _showItemDialog(item: item),
                    onDelete: () => _deleteItem(item),
                  );
                },
              ),
            ),
    );
  }
}
