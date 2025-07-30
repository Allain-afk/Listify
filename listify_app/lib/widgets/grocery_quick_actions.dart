import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item.dart';
import '../screens/add_grocery_screen.dart';

class GroceryQuickActions extends StatelessWidget {
  const GroceryQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryProvider>(
      builder: (context, groceryProvider, child) {
        final completedCount = groceryProvider.completedCount;
        final pendingCount = groceryProvider.pendingCount;
        final totalSpent = groceryProvider.totalSpent;

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Add Item',
                      Icons.add_shopping_cart,
                      Colors.green,
                      () => _addNewItem(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Clear Completed',
                      Icons.clear_all,
                      Colors.orange,
                      () => _clearCompleted(context, groceryProvider),
                      disabled: completedCount == 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Statistics cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      pendingCount.toString(),
                      Icons.schedule,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      completedCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Spent',
                      '\$${totalSpent.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Quick add common items
              _buildQuickAddSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool disabled = false,
  }) {
    return ElevatedButton.icon(
      onPressed: disabled ? null : onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddSection(BuildContext context) {
    final commonItems = [
      {'name': 'Milk', 'price': 3.99, 'category': GroceryCategory.dairy},
      {'name': 'Bread', 'price': 2.49, 'category': GroceryCategory.pantry},
      {'name': 'Bananas', 'price': 1.99, 'category': GroceryCategory.fruits},
      {'name': 'Eggs', 'price': 4.99, 'category': GroceryCategory.dairy},
      {'name': 'Chicken', 'price': 8.99, 'category': GroceryCategory.meat},
      {'name': 'Rice', 'price': 3.49, 'category': GroceryCategory.pantry},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add Common Items',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonItems.map((item) {
            return ActionChip(
              label: Text(item['name'] as String),
              avatar: CircleAvatar(
                backgroundColor: _getCategoryColor(item['category'] as GroceryCategory).withOpacity(0.2),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: _getCategoryColor(item['category'] as GroceryCategory),
                ),
              ),
              onPressed: () => _quickAddItem(context, item),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addNewItem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddGroceryScreen(),
      ),
    );
  }

  void _clearCompleted(BuildContext context, GroceryProvider groceryProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Items'),
        content: const Text('Are you sure you want to remove all completed items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              groceryProvider.clearCompleted();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completed items cleared'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _quickAddItem(BuildContext context, Map<String, dynamic> itemData) {
    final item = GroceryItem(
      name: itemData['name'] as String,
      price: itemData['price'] as double,
      category: itemData['category'] as GroceryCategory,
    );

    context.read<GroceryProvider>().addItem(item);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to list'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(GroceryCategory category) {
    switch (category) {
      case GroceryCategory.fruits:
        return Colors.red;
      case GroceryCategory.vegetables:
        return Colors.green;
      case GroceryCategory.dairy:
        return Colors.blue;
      case GroceryCategory.meat:
        return Colors.orange;
      case GroceryCategory.pantry:
        return Colors.brown;
      case GroceryCategory.beverages:
        return Colors.cyan;
      case GroceryCategory.snacks:
        return Colors.yellow;
      case GroceryCategory.household:
        return Colors.purple;
      case GroceryCategory.other:
        return Colors.grey;
    }
  }
} 