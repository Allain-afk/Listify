import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_item.dart';
import '../services/notification_service.dart';

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
      version: 2, // Incremented version for schema update
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
            dueDate INTEGER,
            notificationTime INTEGER,
            hasNotification INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Add new notification columns for existing databases
          await db.execute('''
            ALTER TABLE items ADD COLUMN notificationTime INTEGER
          ''');
          await db.execute('''
            ALTER TABLE items ADD COLUMN hasNotification INTEGER NOT NULL DEFAULT 0
          ''');
        }
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
        print('Error loading items'); // Removed sensitive error details
      }
      // TODO: Implement proper error logging system
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
      
      // Schedule notification if enabled
      if (item.hasNotification && item.fullNotificationDateTime != null) {
        await NotificationService.instance.scheduleNotification(item);
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item'); // Removed sensitive error details
      }
      // TODO: Implement proper error logging system
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
        final oldItem = _items[index];
        _items[index] = updatedItem;
        
        // Handle notification scheduling
        await _handleNotificationUpdate(oldItem, updatedItem);
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating item'); // Removed sensitive error details
      }
      // TODO: Implement proper error logging system
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
      
      // Cancel notification if task is completed
      if (!item.isCompleted && updatedItem.isCompleted) {
        await NotificationService.instance.cancelNotification(item.id);
      }
      // Reschedule notification if task is uncompleted and has notification
      else if (item.isCompleted && !updatedItem.isCompleted && updatedItem.hasNotification) {
        await NotificationService.instance.scheduleNotification(updatedItem);
      }
      
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

      // Cancel any scheduled notification for this item
      await NotificationService.instance.cancelNotification(id);

      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting item'); // Removed sensitive error details
      }
      // TODO: Implement proper error logging system
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
        print('Error clearing completed items'); // Removed sensitive error details
      }
      // TODO: Implement proper error logging system
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
        print('Error clearing all items'); // Removed sensitive error details
      }
      // TODO: Implement proper error logging system
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

  // Handle notification updates when item is modified
  Future<void> _handleNotificationUpdate(TodoItem oldItem, TodoItem newItem) async {
    // Cancel old notification if it existed
    if (oldItem.hasNotification) {
      await NotificationService.instance.cancelNotification(oldItem.id);
    }

    // Schedule new notification if needed and not completed
    if (newItem.hasNotification && 
        newItem.fullNotificationDateTime != null && 
        !newItem.isCompleted) {
      await NotificationService.instance.scheduleNotification(newItem);
    }
  }
}