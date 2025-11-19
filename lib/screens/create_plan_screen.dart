import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/database_service.dart';
import '../widgets/plan_summary_card.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  static const routeName = '/create-plan';

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final TextEditingController _targetCostController = TextEditingController();
  DateTime? _selectedDate;
  List<FoodItem> _foodItems = [];
  final Map<int, FoodItem> _selectedItems = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await DatabaseService.instance.getFoodItems();
    setState(() {
      _foodItems = items;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _targetCostController.dispose();
    super.dispose();
  }

  double get _targetCost => double.tryParse(_targetCostController.text) ?? 0;

  double get _totalSelected =>
      _selectedItems.values.fold(0, (previousValue, element) => previousValue + element.cost);

  String get _dateLabel =>
      _selectedDate == null ? 'Select Date' : _formatDate(_selectedDate!);

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _toggleSelection(FoodItem item, bool? selected) {
    if (selected == true) {
      final target = _targetCost;
      if (target <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a target cost before selecting items.')),
        );
        return;
      }
      if (_totalSelected + item.cost > target + 1e-6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selection exceeds the target cost.')),
        );
        return;
      }
      final key = item.id;
      if (key == null) return;
      setState(() => _selectedItems[key] = item);
    } else {
      final key = item.id;
      if (key == null) return;
      setState(() => _selectedItems.remove(key));
    }
  }

  Future<void> _savePlan() async {
    final date = _selectedDate;
    final target = _targetCost;
    if (date == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please choose a date.')));
      return;
    }
    if (target <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a valid target cost.')));
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select at least one food item.')));
      return;
    }

    await DatabaseService.instance.saveOrderPlan(
      _formatDate(date),
      target,
      _selectedItems.values.toList(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order Plan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _pickDate,
                          child: Text(_dateLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _targetCostController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Target Cost',
                            prefixText: '\$',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select Food Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _foodItems.length,
                      itemBuilder: (context, index) {
                        final item = _foodItems[index];
                        final isSelected = _selectedItems.containsKey(item.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) => _toggleSelection(item, value),
                          title: Text(item.name),
                          subtitle: Text('\$${item.cost.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
                  PlanSummaryCard(
                    date: _selectedDate == null ? 'No date' : _formatDate(_selectedDate!),
                    targetCost: _targetCost,
                    totalCost: _totalSelected,
                    items: _selectedItems.values.map((e) => e.name).toList(),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _savePlan,
                      child: const Text('Save Plan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
