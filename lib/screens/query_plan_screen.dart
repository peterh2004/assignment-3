import 'package:flutter/material.dart';

import '../models/order_plan.dart';
import '../services/database_service.dart';
import '../widgets/plan_summary_card.dart';

class QueryPlanScreen extends StatefulWidget {
  const QueryPlanScreen({super.key});

  static const routeName = '/query-plan';

  @override
  State<QueryPlanScreen> createState() => _QueryPlanScreenState();
}

class _QueryPlanScreenState extends State<QueryPlanScreen> {
  OrderPlan? _orderPlan;
  bool _isLoading = false;
  String? _dateLabel;

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickDateAndQuery() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    final formatted = _formatDate(picked);
    setState(() {
      _isLoading = true;
      _dateLabel = formatted;
    });
    final plan = await DatabaseService.instance.getOrderPlanByDate(formatted);
    setState(() {
      _orderPlan = plan;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = _orderPlan;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Order Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: _pickDateAndQuery,
              icon: const Icon(Icons.calendar_month),
              label: Text(_dateLabel == null ? 'Select date' : _dateLabel!),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (plan != null)
              Expanded(
                child: SingleChildScrollView(
                  child: PlanSummaryCard(
                    date: plan.date,
                    targetCost: plan.targetCost,
                    totalCost:
                        plan.selectedItems.fold<double>(0, (sum, item) => sum + item.cost),
                    items: plan.selectedItems.map((e) => e.name).toList(),
                  ),
                ),
              )
            else if (_dateLabel != null)
              Expanded(
                child: Center(
                  child: Text(
                    'No order plan saved for $_dateLabel',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    'Select a date to view an order plan.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
