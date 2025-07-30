import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/grocery_item.dart';

class GroceryProvider extends ChangeNotifier {
  List<GroceryItem> _items = [];
  bool _isLoading = false;
  Database? _database;

  List<GroceryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  int get completedCount => _items.where((item) => item.isCompleted).length;
  int get pendingCount => _items.where((item) => !item.isCompleted).length;
  double get totalSpent => _items.where((item) => item.isCompleted).fold(0.0, (sum, item) => sum + item.totalPrice);
  double get totalBudget => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get remainingBudget => totalBudget - totalSpent;

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'listify_grocery.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE grocery_items(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            category INTEGER NOT NULL,
            isCompleted INTEGER NOT NULL,
            createdAt INTEGER NOT NULL,
            completedAt INTEGER,
            notes TEXT
          )
        ''');
      },
    );
  }

  // Load items from database
  Future<void> loadItems() async {
    _setLoading(true);
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'grocery_items',
        orderBy: 'createdAt DESC',
      );

      _items = maps.map((item) => GroceryItem.fromMap(item)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading grocery items: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Add new item
  Future<void> addItem(GroceryItem item) async {
    try {
      final db = await database;
      await db.insert('grocery_items', item.toMap());
      
      _items.insert(0, item);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding grocery item: $e');
      }
    }
  }

  // Update existing item
  Future<void> updateItem(GroceryItem updatedItem) async {
    try {
      final db = await database;
      await db.update(
        'grocery_items',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [updatedItem.id],
      );

      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating grocery item: $e');
      }
    }
  }

  // Toggle item completion status
  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _items[index];
      final updatedItem = item.copyWith(
        isCompleted: !item.isCompleted,
        completedAt: !item.isCompleted ? DateTime.now() : null,
      );
      
      await updateItem(updatedItem);
    }
  }

  // Delete item
  Future<void> deleteItem(String id) async {
    try {
      final db = await database;
      await db.delete(
        'grocery_items',
        where: 'id = ?',
        whereArgs: [id],
      );

      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting grocery item: $e');
      }
    }
  }

  // Clear completed items
  Future<void> clearCompleted() async {
    try {
      final db = await database;
      await db.delete(
        'grocery_items',
        where: 'isCompleted = ?',
        whereArgs: [1],
      );

      _items.removeWhere((item) => item.isCompleted);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing completed grocery items: $e');
      }
    }
  }

  // Clear all items
  Future<void> clearAll() async {
    try {
      final db = await database;
      await db.delete('grocery_items');

      _items.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all grocery items: $e');
      }
    }
  }

  // Search items
  List<GroceryItem> searchItems(String query) {
    if (query.isEmpty) return _items;
    
    return _items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
             (item.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // Filter items by completion status
  List<GroceryItem> getItemsByStatus({required bool completed}) {
    return _items.where((item) => item.isCompleted == completed).toList();
  }

  // Filter items by category
  List<GroceryItem> getItemsByCategory(GroceryCategory category) {
    return _items.where((item) => item.category == category).toList();
  }

  // Sort items by different criteria
  void sortItems(String criteria) {
    switch (criteria) {
      case 'name':
        _items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        _items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'created':
        _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'category':
        _items.sort((a, b) => a.category.index.compareTo(b.category.index));
        break;
      case 'status':
        _items.sort((a, b) => a.isCompleted.toString().compareTo(b.isCompleted.toString()));
        break;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final completedItems = _items.where((item) => item.isCompleted).toList();
    final pendingItems = _items.where((item) => !item.isCompleted).toList();
    
    return {
      'total': _items.length,
      'completed': completedCount,
      'pending': pendingCount,
      'totalSpent': totalSpent,
      'totalBudget': totalBudget,
      'remainingBudget': remainingBudget,
      'categories': GroceryCategory.values.map((category) {
        final categoryItems = _items.where((item) => item.category == category).toList();
        return {
          'category': category,
          'count': categoryItems.length,
          'total': categoryItems.fold(0.0, (sum, item) => sum + item.totalPrice),
        };
      }).toList(),
    };
  }

  // Get category statistics
  Map<GroceryCategory, double> getCategoryTotals() {
    final Map<GroceryCategory, double> totals = {};
    
    for (final item in _items) {
      totals[item.category] = (totals[item.category] ?? 0.0) + item.totalPrice;
    }
    
    return totals;
  }
} 