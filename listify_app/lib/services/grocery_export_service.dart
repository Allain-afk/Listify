import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_item.dart';

class GroceryExportService {
  static final GroceryExportService _instance = GroceryExportService._internal();
  static GroceryExportService get instance => _instance;
  GroceryExportService._internal();

  // Export to CSV format
  Future<String> exportToCSV(List<GroceryItem> items) async {
    final csv = StringBuffer();
    
    // Add header
    csv.writeln('Name,Price,Quantity,Category,Status,Notes,Total Price');
    
    // Add data rows
    for (final item in items) {
      csv.writeln([
        '"${item.name}"',
        item.price.toString(),
        item.quantity.toString(),
        _getCategoryName(item.category),
        item.isCompleted ? 'Completed' : 'Pending',
        '"${item.notes ?? ''}"',
        item.totalPrice.toString(),
      ].join(','));
    }
    
    return csv.toString();
  }

  // Export to JSON format
  Future<String> exportToJSON(List<GroceryItem> items) async {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalItems': items.length,
      'completedItems': items.where((item) => item.isCompleted).length,
      'totalSpent': items.where((item) => item.isCompleted).fold(0.0, (sum, item) => sum + item.totalPrice),
      'items': items.map((item) => item.toMap()).toList(),
    };
    
    return jsonEncode(data);
  }

  // Export to shopping list format (simple text)
  Future<String> exportToShoppingList(List<GroceryItem> items) async {
    final buffer = StringBuffer();
    buffer.writeln('Shopping List');
    buffer.writeln('Generated on: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('');
    
    // Group by category
    final groupedItems = <String, List<GroceryItem>>{};
    for (final item in items) {
      final categoryName = _getCategoryName(item.category);
      groupedItems.putIfAbsent(categoryName, () => []).add(item);
    }
    
    // Write items by category
    for (final category in groupedItems.keys) {
      buffer.writeln('$category:');
      for (final item in groupedItems[category]!) {
        final status = item.isCompleted ? '✓' : '□';
        buffer.writeln('  $status ${item.quantity}x ${item.name} - \$${item.totalPrice.toStringAsFixed(2)}');
        if (item.notes != null && item.notes!.isNotEmpty) {
          buffer.writeln('    Note: ${item.notes}');
        }
      }
      buffer.writeln('');
    }
    
    // Add summary
    final totalSpent = items.where((item) => item.isCompleted).fold(0.0, (sum, item) => sum + item.totalPrice);
    final totalBudget = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    buffer.writeln('Summary:');
    buffer.writeln('  Total Items: ${items.length}');
    buffer.writeln('  Completed: ${items.where((item) => item.isCompleted).length}');
    buffer.writeln('  Total Spent: \$${totalSpent.toStringAsFixed(2)}');
    buffer.writeln('  Remaining: \$${(totalBudget - totalSpent).toStringAsFixed(2)}');
    
    return buffer.toString();
  }

  // Save file to device
  Future<String?> saveToFile(String content, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file: $e');
      }
      return null;
    }
  }

  // Share file
  Future<void> shareFile(String content, String filename, String mimeType) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Grocery List from Listify',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing file: $e');
      }
    }
  }

  // Import from JSON
  Future<List<GroceryItem>> importFromJSON(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final itemsList = data['items'] as List;
      
      return itemsList.map((itemData) => GroceryItem.fromMap(itemData)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error importing JSON: $e');
      }
      return [];
    }
  }

  // Import from CSV
  Future<List<GroceryItem>> importFromCSV(String csvString) async {
    try {
      final lines = csvString.split('\n');
      if (lines.length < 2) return [];
      
      final items = <GroceryItem>[];
      
      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final values = _parseCSVLine(line);
        if (values.length >= 4) {
          try {
            final name = values[0].replaceAll('"', '');
            final price = double.parse(values[1]);
            final quantity = int.parse(values[2]);
            final category = _parseCategory(values[3]);
            final isCompleted = values[4].toLowerCase() == 'completed';
            final notes = values.length > 5 ? values[5].replaceAll('"', '') : null;
            
            items.add(GroceryItem(
              name: name,
              price: price,
              quantity: quantity,
              category: category,
              isCompleted: isCompleted,
              notes: notes,
            ));
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing CSV line $i: $e');
            }
          }
        }
      }
      
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('Error importing CSV: $e');
      }
      return [];
    }
  }

  // Parse CSV line (handles quoted values)
  List<String> _parseCSVLine(String line) {
    final result = <String>[];
    String current = '';
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    result.add(current.trim());
    return result;
  }

  // Parse category from string
  GroceryCategory _parseCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fruits':
        return GroceryCategory.fruits;
      case 'vegetables':
        return GroceryCategory.vegetables;
      case 'dairy':
        return GroceryCategory.dairy;
      case 'meat':
        return GroceryCategory.meat;
      case 'pantry':
        return GroceryCategory.pantry;
      case 'beverages':
        return GroceryCategory.beverages;
      case 'snacks':
        return GroceryCategory.snacks;
      case 'household':
        return GroceryCategory.household;
      default:
        return GroceryCategory.other;
    }
  }

  // Get category name
  String _getCategoryName(GroceryCategory category) {
    switch (category) {
      case GroceryCategory.fruits:
        return 'Fruits';
      case GroceryCategory.vegetables:
        return 'Vegetables';
      case GroceryCategory.dairy:
        return 'Dairy';
      case GroceryCategory.meat:
        return 'Meat';
      case GroceryCategory.pantry:
        return 'Pantry';
      case GroceryCategory.beverages:
        return 'Beverages';
      case GroceryCategory.snacks:
        return 'Snacks';
      case GroceryCategory.household:
        return 'Household';
      case GroceryCategory.other:
        return 'Other';
    }
  }

  // Generate filename with timestamp
  String _generateFilename(String extension) {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'grocery_list_$timestamp.$extension';
  }

  // Export and share as CSV
  Future<void> exportAndShareCSV(List<GroceryItem> items) async {
    final csv = await exportToCSV(items);
    final filename = _generateFilename('csv');
    await shareFile(csv, filename, 'text/csv');
  }

  // Export and share as JSON
  Future<void> exportAndShareJSON(List<GroceryItem> items) async {
    final json = await exportToJSON(items);
    final filename = _generateFilename('json');
    await shareFile(json, filename, 'application/json');
  }

  // Export and share as shopping list
  Future<void> exportAndShareShoppingList(List<GroceryItem> items) async {
    final shoppingList = await exportToShoppingList(items);
    final filename = _generateFilename('txt');
    await shareFile(shoppingList, filename, 'text/plain');
  }
} 