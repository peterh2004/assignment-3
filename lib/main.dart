import 'package:flutter/material.dart';

import 'screens/create_plan_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manage_food_items_screen.dart';
import 'screens/query_plan_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  runApp(const FoodPlannerApp());
}

class FoodPlannerApp extends StatelessWidget {
  const FoodPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Order Planner',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        CreatePlanScreen.routeName: (_) => const CreatePlanScreen(),
        QueryPlanScreen.routeName: (_) => const QueryPlanScreen(),
        ManageFoodItemsScreen.routeName: (_) => const ManageFoodItemsScreen(),
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
