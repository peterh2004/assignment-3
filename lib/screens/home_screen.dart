import 'package:flutter/material.dart';

import 'create_plan_screen.dart';
import 'manage_food_items_screen.dart';
import 'query_plan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Order Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(CreatePlanScreen.routeName),
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Create Order Plan'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(QueryPlanScreen.routeName),
                icon: const Icon(Icons.search),
                label: const Text('Query Order Plan'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed(ManageFoodItemsScreen.routeName),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Manage Food Items'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
