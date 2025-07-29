import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_item.dart';

class ItemProvider extends ChangeNotifier {
  List<TodoItem> _items = [];
  bool _isLoading = false;
  Database? _database;

  List<TodoItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  int get completedCount => _items.where((item) => item.isCompleted).length;
  int get pendingCount => _items.where((item) => !item.isCompleted).length;

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'listify.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE items(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER NOT NULL,
            priority INTEGER NOT NULL,
            createdAt INTEGER NOT NULL,
            completedAt INTEGER,
            dueDate INTEGER
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
        'items',
        orderBy: 'createdAt DESC',
      );

      _items = maps.map((item) => TodoItem.fromMap(item)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading items: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Add new item
  Future<void> addItem(TodoItem item) async {
    try {
      final db = await database;
      await db.insert('items', item.toMap());
      
      _items.insert(0, item);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item: $e');
      }
    }
  }

  // Update existing item
  Future<void> updateItem(TodoItem updatedItem) async {
    try {
      final db = await database;
      await db.update(
        'items',
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
        print('Error updating item: $e');
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
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );

      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting item: $e');
      }
    }
  }

  // Clear completed items
  Future<void> clearCompleted() async {
    try {
      final db = await database;
      await db.delete(
        'items',
        where: 'isCompleted = ?',
        whereArgs: [1],
      );

      _items.removeWhere((item) => item.isCompleted);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing completed items: $e');
      }
    }
  }

  // Clear all items
  Future<void> clearAll() async {
    try {
      final db = await database;
      await db.delete('items');

      _items.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all items: $e');
      }
    }
  }

  // Search items
  List<TodoItem> searchItems(String query) {
    if (query.isEmpty) return _items;
    
    return _items.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase()) ||
             item.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter items by completion status
  List<TodoItem> getItemsByStatus({required bool completed}) {
    return _items.where((item) => item.isCompleted == completed).toList();
  }

  // Filter items by priority
  List<TodoItem> getItemsByPriority(Priority priority) {
    return _items.where((item) => item.priority == priority).toList();
  }

  // Sort items by different criteria
  void sortItems(String criteria) {
    switch (criteria) {
      case 'title':
        _items.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'created':
        _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'priority':
        _items.sort((a, b) => b.priority.index.compareTo(a.priority.index));
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
  Map<String, int> getStatistics() {
    return {
      'total': _items.length,
      'completed': completedCount,
      'pending': pendingCount,
      'high_priority': _items.where((item) => item.priority == Priority.high).length,
      'medium_priority': _items.where((item) => item.priority == Priority.medium).length,
      'low_priority': _items.where((item) => item.priority == Priority.low).length,
    };
  }
}