import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item.dart';
import '../services/grocery_export_service.dart';
import '../widgets/grocery_budget_widget.dart';

class GrocerySettingsScreen extends StatefulWidget {
  const GrocerySettingsScreen({super.key});

  @override
  State<GrocerySettingsScreen> createState() => _GrocerySettingsScreenState();
}

class _GrocerySettingsScreenState extends State<GrocerySettingsScreen> {
  final _budgetController = TextEditingController();
  bool _showCompletedItems = true;
  bool _groupByCategory = true;
  bool _showPrices = true;
  String _sortBy = 'created';
  bool _notificationsEnabled = false;
  bool _exportInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // TODO: Load settings from SharedPreferences
    setState(() {
      _showCompletedItems = true;
      _groupByCategory = true;
      _showPrices = true;
      _sortBy = 'created';
      _notificationsEnabled = false;
    });
  }

  Future<void> _saveSettings() async {
    // TODO: Save settings to SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Grocery Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, groceryProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget Settings
                _buildBudgetSection(),
                const SizedBox(height: 24),
                
                // Display Settings
                _buildDisplaySection(),
                const SizedBox(height: 24),
                
                // Export Options
                _buildExportSection(groceryProvider),
                const SizedBox(height: 24),
                
                // Data Management
                _buildDataSection(groceryProvider),
                const SizedBox(height: 24),
                
                // Notifications
                _buildNotificationSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GroceryBudgetWidget(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Monthly Budget Limit',
                      hintText: 'Enter amount',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final budget = double.tryParse(_budgetController.text);
                    if (budget != null && budget > 0) {
                      // TODO: Save budget limit
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Budget limit set to \$${budget.toStringAsFixed(2)}'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Completed Items'),
              subtitle: const Text('Display items that have been purchased'),
              value: _showCompletedItems,
              onChanged: (value) {
                setState(() {
                  _showCompletedItems = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Group by Category'),
              subtitle: const Text('Organize items by grocery categories'),
              value: _groupByCategory,
              onChanged: (value) {
                setState(() {
                  _groupByCategory = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Show Prices'),
              subtitle: const Text('Display item prices and totals'),
              value: _showPrices,
              onChanged: (value) {
                setState(() {
                  _showPrices = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Sort Items By',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'created', child: Text('Date Added')),
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'price', child: Text('Price')),
                DropdownMenuItem(value: 'category', child: Text('Category')),
                DropdownMenuItem(value: 'status', child: Text('Status')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection(GroceryProvider groceryProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportInProgress ? null : () => _exportList(groceryProvider, 'csv'),
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export CSV'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportInProgress ? null : () => _exportList(groceryProvider, 'json'),
                    icon: const Icon(Icons.code),
                    label: const Text('Export JSON'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportInProgress ? null : () => _exportList(groceryProvider, 'shopping'),
                icon: const Icon(Icons.share),
                label: const Text('Share Shopping List'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_exportInProgress) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(GroceryProvider groceryProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showClearDialog(groceryProvider, 'completed'),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showClearDialog(groceryProvider, 'all'),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _importData(),
                icon: const Icon(Icons.file_upload),
                label: const Text('Import Data'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get reminders for grocery shopping'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            if (_notificationsEnabled) ...[
              const SizedBox(height: 16),
              const Text(
                'Notification Settings',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              // TODO: Add more notification settings
              const Text(
                'Configure notification preferences here...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportList(GroceryProvider groceryProvider, String format) async {
    setState(() {
      _exportInProgress = true;
    });

    try {
      switch (format) {
        case 'csv':
          await GroceryExportService.instance.exportAndShareCSV(groceryProvider.items);
          break;
        case 'json':
          await GroceryExportService.instance.exportAndShareJSON(groceryProvider.items);
          break;
        case 'shopping':
          await GroceryExportService.instance.exportAndShareShoppingList(groceryProvider.items);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _exportInProgress = false;
      });
    }
  }

  void _showClearDialog(GroceryProvider groceryProvider, String type) {
    final title = type == 'completed' ? 'Clear Completed Items' : 'Clear All Items';
    final message = type == 'completed' 
      ? 'Are you sure you want to remove all completed items?'
      : 'Are you sure you want to remove all items? This action cannot be undone.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (type == 'completed') {
                groceryProvider.clearCompleted();
              } else {
                groceryProvider.clearAll();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${type == 'completed' ? 'Completed' : 'All'} items cleared'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData() async {
    // TODO: Implement file picker for importing data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import functionality coming soon'),
      ),
    );
  }
} 