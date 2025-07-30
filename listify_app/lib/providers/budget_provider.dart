import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/budget_settings.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetSettings? _budgetSettings;
  bool _isLoading = false;
  Database? _database;

  BudgetSettings? get budgetSettings => _budgetSettings;
  bool get isLoading => _isLoading;

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'listify_budget.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE budget_settings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            budget REAL NOT NULL,
            currency INTEGER NOT NULL,
            lastUpdated INTEGER NOT NULL
          )
        ''');
        
        // Insert default budget settings
        await db.insert('budget_settings', {
          'budget': 0.0,
          'currency': 0, // PHP
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        });
      },
    );
  }

  // Load budget settings from database
  Future<void> loadBudgetSettings() async {
    _setLoading(true);
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'budget_settings',
        orderBy: 'lastUpdated DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _budgetSettings = BudgetSettings.fromMap(maps.first);
      } else {
        // Create default settings if none exist
        _budgetSettings = BudgetSettings(budget: 0.0, currency: Currency.php);
        await saveBudgetSettings(_budgetSettings!);
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading budget settings: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Save budget settings to database
  Future<void> saveBudgetSettings(BudgetSettings settings) async {
    try {
      final db = await database;
      await db.insert(
        'budget_settings',
        settings.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _budgetSettings = settings;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving budget settings: $e');
      }
    }
  }

  // Update budget
  Future<void> updateBudget(double budget) async {
    if (_budgetSettings != null) {
      final updatedSettings = _budgetSettings!.copyWith(budget: budget);
      await saveBudgetSettings(updatedSettings);
    }
  }

  // Update currency
  Future<void> updateCurrency(Currency currency) async {
    if (_budgetSettings != null) {
      final updatedSettings = _budgetSettings!.copyWith(currency: currency);
      await saveBudgetSettings(updatedSettings);
    }
  }

  // Reset budget to zero
  Future<void> resetBudget() async {
    await updateBudget(0.0);
  }

  // Remove budget (set to null)
  Future<void> removeBudget() async {
    try {
      final db = await database;
      await db.delete('budget_settings');
      _budgetSettings = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing budget: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Format amount with current currency
  String formatAmount(double amount) {
    if (_budgetSettings != null) {
      return _budgetSettings!.formatAmount(amount);
    }
    return '\$${amount.toStringAsFixed(2)}'; // Default to USD symbol
  }

  // Get current currency symbol
  String get currencySymbol {
    return _budgetSettings?.currencySymbol ?? '\$';
  }

  // Get current currency name
  String get currencyName {
    return _budgetSettings?.currencyName ?? 'US Dollar';
  }

  // Check if budget is set
  bool get hasBudget => _budgetSettings != null && _budgetSettings!.budget > 0;

  // Get budget amount
  double get budgetAmount => _budgetSettings?.budget ?? 0.0;
} 