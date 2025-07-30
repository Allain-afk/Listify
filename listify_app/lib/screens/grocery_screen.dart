import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/grocery_provider.dart';
import '../providers/budget_provider.dart';
import '../models/grocery_item.dart';
import '../widgets/grocery_item_card.dart';
import 'add_grocery_screen.dart';
import 'budget_settings_screen.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final Map<String, GroceryItem> _recentlyDeleted = {};

  @override
  void initState() {
    super.initState();
    // Load items and budget settings when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().loadItems();
      context.read<BudgetProvider>().loadBudgetSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            _buildHeader(),
            
            // Content area
            Expanded(
              child: Consumer<GroceryProvider>(
                builder: (context, groceryProvider, child) {
                  if (groceryProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  if (groceryProvider.items.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: [
                      // Statistics section
                      _buildStatsSection(groceryProvider),
                      
                      // Grocery list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: groceryProvider.items.length,
                          itemBuilder: (context, index) {
                            final item = groceryProvider.items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Slidable(
                                key: ValueKey(item.id),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) => _deleteItem(groceryProvider, item),
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ],
                                ),
                                child: GroceryItemCard(
                                  item: item,
                                  onToggle: () => groceryProvider.toggleItem(item.id),
                                  onEdit: () => _editItem(item),
                                  onDelete: () => _deleteItem(groceryProvider, item),
                                  showMenu: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grocery List',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Shopping & Budget Tracker',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<GroceryProvider>(
            builder: (context, groceryProvider, child) {
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                color: Theme.of(context).colorScheme.surface,
                elevation: 0,
                offset: const Offset(-8, 8),
                                           onSelected: (value) {
                             switch (value) {
                               case 'budget_settings':
                                 _openBudgetSettings();
                                 break;
                               case 'clear_completed':
                                 groceryProvider.clearCompleted();
                                 break;
                               case 'clear_all':
                                 _showClearAllDialog(context, groceryProvider);
                                 break;
                               case 'sort_name':
                                 groceryProvider.sortItems('name');
                                 break;
                               case 'sort_price':
                                 groceryProvider.sortItems('price');
                                 break;
                               case 'sort_category':
                                 groceryProvider.sortItems('category');
                                 break;
                             }
                           },
                                           itemBuilder: (BuildContext context) => [
                             PopupMenuItem<String>(
                               value: 'budget_settings',
                               child: Row(
                                 children: [
                                   Icon(
                                     Icons.account_balance_wallet,
                                     size: 18,
                                     color: Theme.of(context).colorScheme.secondary,
                                   ),
                                   const SizedBox(width: 12),
                                   Text(
                                     'Budget Settings',
                                     style: Theme.of(context).textTheme.bodyMedium,
                                   ),
                                 ],
                               ),
                             ),
                             const PopupMenuDivider(),
                             PopupMenuItem<String>(
                               value: 'sort_name',
                               child: Row(
                                 children: [
                                   Icon(
                                     Icons.sort_by_alpha,
                                     size: 18,
                                     color: Theme.of(context).colorScheme.secondary,
                                   ),
                                   const SizedBox(width: 12),
                                   Text(
                                     'Sort by Name',
                                     style: Theme.of(context).textTheme.bodyMedium,
                                   ),
                                 ],
                               ),
                             ),
                  PopupMenuItem<String>(
                    value: 'sort_price',
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sort by Price',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'sort_category',
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sort by Category',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'clear_completed',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Clear Completed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red.shade500,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Clear All',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(GroceryProvider groceryProvider) {
    final stats = groceryProvider.getStatistics();
    
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final hasBudget = budgetProvider.hasBudget;
        final budgetAmount = budgetProvider.budgetAmount;
        final totalSpent = stats['totalSpent'];
        final remainingBudget = hasBudget ? budgetAmount - totalSpent : 0.0;
        final budgetUsage = hasBudget && budgetAmount > 0 
            ? (totalSpent / budgetAmount).clamp(0.0, 1.0)
            : 0.0;
        
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              // Budget Overview
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Budget',
                      hasBudget 
                          ? budgetProvider.formatAmount(budgetAmount)
                          : 'Not Set',
                      Icons.account_balance_wallet,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Spent',
                      budgetProvider.formatAmount(totalSpent),
                      Icons.shopping_cart,
                      Colors.green,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Remaining',
                      hasBudget 
                          ? budgetProvider.formatAmount(remainingBudget)
                          : '-',
                      Icons.savings,
                      hasBudget && remainingBudget < 0 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
              
              if (hasBudget) ...[
                const SizedBox(height: 16),
                
                // Progress bar
                LinearProgressIndicator(
                  value: budgetUsage,
                  backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    budgetUsage > 1.0 ? Colors.red : Colors.green,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '${(budgetUsage * 100).clamp(0.0, 100.0).toStringAsFixed(1)}% of budget used',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
              
              if (!hasBudget) ...[
                const SizedBox(height: 16),
                
                OutlinedButton.icon(
                  onPressed: () => _openBudgetSettings(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Set Budget'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your grocery list is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding items to track your shopping and budget',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addNewItem(context),
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewItem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGroceryScreen(),
      ),
    );
  }

  void _openBudgetSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BudgetSettingsScreen(),
      ),
    );
  }

  void _editItem(GroceryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGroceryScreen(item: item),
      ),
    );
  }

  void _deleteItem(GroceryProvider provider, GroceryItem item) {
    // Store the item for potential undo
    _recentlyDeleted[item.id] = item;
    
    // Remove from provider
    provider.deleteItem(item.id);
    
    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item "${item.name}" deleted'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => _undoDelete(provider, item.id),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
    
    // Clear from recently deleted after some time if not undone
    Future.delayed(const Duration(seconds: 5), () {
      _recentlyDeleted.remove(item.id);
    });
  }

  void _undoDelete(GroceryProvider provider, String itemId) {
    final item = _recentlyDeleted[itemId];
    if (item != null) {
      provider.addItem(item);
      _recentlyDeleted.remove(itemId);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item "${item.name}" restored'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showClearAllDialog(BuildContext context, GroceryProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          title: Text(
            'Clear All Items',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete all grocery items? This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.clearAll();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
} 