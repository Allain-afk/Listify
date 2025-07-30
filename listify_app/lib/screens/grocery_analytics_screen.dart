import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item.dart';

class GroceryAnalyticsScreen extends StatefulWidget {
  const GroceryAnalyticsScreen({super.key});

  @override
  State<GroceryAnalyticsScreen> createState() => _GroceryAnalyticsScreenState();
}

class _GroceryAnalyticsScreenState extends State<GroceryAnalyticsScreen> {
  String _selectedPeriod = 'All Time';
  final List<String> _periods = ['All Time', 'This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Grocery Analytics'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, groceryProvider, child) {
          final stats = groceryProvider.getStatistics();
          final categoryTotals = groceryProvider.getCategoryTotals();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewCards(stats),
                const SizedBox(height: 24),
                
                // Spending Chart
                _buildSpendingChart(categoryTotals),
                const SizedBox(height: 24),
                
                // Category Breakdown
                _buildCategoryBreakdown(categoryTotals),
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildRecentActivity(groceryProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Items',
          stats['total'].toString(),
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildStatCard(
          'Completed',
          stats['completed'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Total Spent',
          '\$${stats['totalSpent'].toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.orange,
        ),
        _buildStatCard(
          'Remaining',
          '\$${stats['remainingBudget'].toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingChart(Map<GroceryCategory, double> categoryTotals) {
    final data = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.map((entry) {
                    final percentage = entry.value / categoryTotals.values.fold(0.0, (sum, value) => sum + value);
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${(percentage * 100).toStringAsFixed(1)}%',
                      color: _getCategoryColor(entry.key),
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(data),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<MapEntry<GroceryCategory, double>> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCategoryColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _getCategoryName(entry.key),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryBreakdown(Map<GroceryCategory, double> categoryTotals) {
    final data = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...data.map((entry) => _buildCategoryItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(GroceryCategory category, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getCategoryName(category),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(GroceryProvider groceryProvider) {
    final recentItems = groceryProvider.items.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recentItems.isEmpty)
              Center(
                child: Text(
                  'No recent activity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...recentItems.map((item) => _buildActivityItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(GroceryItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
} 