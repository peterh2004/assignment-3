import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/food_item.dart';
import '../models/order_plan.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'food_planner.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE food_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            cost REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE order_plan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL UNIQUE,
            target_cost REAL NOT NULL,
            selected_items TEXT NOT NULL
          )
        ''');
      },
    );
    await _ensureDefaultFoodItems(db);
    return db;
  }

  Future<void> _ensureDefaultFoodItems(Database db) async {
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM food_items');
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    if (count >= 20) return;

    final defaults = <Map<String, dynamic>>[
      {'name': 'Margherita Pizza', 'cost': 9.99},
      {'name': 'BBQ Chicken Pizza', 'cost': 12.49},
      {'name': 'Veggie Burger', 'cost': 8.49},
      {'name': 'Grilled Chicken Wrap', 'cost': 7.99},
      {'name': 'Caesar Salad', 'cost': 6.50},
      {'name': 'Quinoa Bowl', 'cost': 10.25},
      {'name': 'Fish Tacos', 'cost': 11.25},
      {'name': 'Pasta Primavera', 'cost': 13.00},
      {'name': 'Steak Sandwich', 'cost': 14.75},
      {'name': 'Avocado Toast', 'cost': 5.75},
      {'name': 'Chicken Noodle Soup', 'cost': 6.25},
      {'name': 'Tomato Basil Soup', 'cost': 5.25},
      {'name': 'Sushi Combo', 'cost': 16.99},
      {'name': 'Pad Thai', 'cost': 12.99},
      {'name': 'Falafel Platter', 'cost': 9.50},
      {'name': 'Beef Burrito', 'cost': 8.99},
      {'name': 'Turkey Club Sandwich', 'cost': 9.25},
      {'name': 'Greek Salad', 'cost': 7.25},
      {'name': 'Shrimp Stir Fry', 'cost': 14.25},
      {'name': 'Chocolate Cake', 'cost': 4.99},
    ];
    final needed = 20 - count;
    final safeNeeded = needed.clamp(0, defaults.length).toInt();
    for (final item in defaults.take(safeNeeded)) {
      await db.insert('food_items', item);
    }
  }

  Future<List<FoodItem>> getFoodItems() async {
    final db = await database;
    final maps = await db.query('food_items', orderBy: 'name');
    return maps.map((e) => FoodItem.fromMap(e)).toList();
  }

  Future<int> addFoodItem(String name, double cost) async {
    final db = await database;
    return db.insert('food_items', {'name': name, 'cost': cost});
  }

  Future<int> updateFoodItem(int id, String name, double cost) async {
    final db = await database;
    return db.update(
      'food_items',
      {'name': name, 'cost': cost},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFoodItem(int id) async {
    final db = await database;
    return db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveOrderPlan(String date, double targetCost, List<FoodItem> items) async {
    final db = await database;
    final payload = {
      'date': date,
      'target_cost': targetCost,
      'selected_items': jsonEncode(items.map((e) => e.toMap()).toList()),
    };
    await db.insert(
      'order_plan',
      payload,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<OrderPlan?> getOrderPlanByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'order_plan',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return OrderPlan.fromMap(result.first);
  }
}
