import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';
import '../models/todo_item.dart';
import '../widgets/home_widget.dart';

class WidgetBarScreen extends StatelessWidget {
  const WidgetBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Quick Stats
                    _buildQuickStats(context),
                    
                    const SizedBox(height: 16),
                    
                    // Task Widget
                    const HomeWidget(),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Actions
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                'Listify',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Your Task Dashboard',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _toggleTheme(context),
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, child) {
        final stats = itemProvider.getStatistics();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total',
                  stats['total']?.toString() ?? '0',
                  Icons.list_alt,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Pending',
                  stats['pending']?.toString() ?? '0',
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completed',
                  stats['completed']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'View All Tasks',
                  Icons.list,
                  Theme.of(context).colorScheme.primary,
                  () => _viewAllTasks(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Completed Tasks',
                  Icons.check_circle,
                  Colors.green,
                  () => _viewCompletedTasks(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'High Priority',
                  Icons.priority_high,
                  Colors.red,
                  () => _viewHighPriorityTasks(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Settings',
                  Icons.settings,
                  Theme.of(context).colorScheme.secondary,
                  () => _openSettings(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  void _toggleTheme(BuildContext context) {
    context.read<ThemeProvider>().toggleTheme();
  }

  void _viewAllTasks(BuildContext context) {
    // Navigate to main task list
    Navigator.of(context).pushNamed('/');
  }

  void _viewCompletedTasks(BuildContext context) {
    // Show completed tasks dialog or navigate to filtered view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completed Tasks'),
        content: Consumer<ItemProvider>(
          builder: (context, itemProvider, child) {
            final completedTasks = itemProvider.getItemsByStatus(completed: true);
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: completedTasks.length,
                itemBuilder: (context, index) {
                  final task = completedTasks[index];
                  return ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: task.description.isNotEmpty
                        ? Text(
                            task.description,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                            ),
                          )
                        : null,
                    trailing: Text(
                      task.completedAt != null
                          ? '${task.completedAt!.day}/${task.completedAt!.month}'
                          : '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewHighPriorityTasks(BuildContext context) {
    // Show high priority tasks dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('High Priority Tasks'),
        content: Consumer<ItemProvider>(
          builder: (context, itemProvider, child) {
            final highPriorityTasks = itemProvider.getItemsByPriority(Priority.high);
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: highPriorityTasks.length,
                itemBuilder: (context, index) {
                  final task = highPriorityTasks[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.priority_high,
                      color: Colors.red,
                    ),
                    title: Text(task.title),
                    subtitle: task.description.isNotEmpty
                        ? Text(task.description)
                        : null,
                    trailing: task.dueDate != null
                        ? Text(
                            '${task.dueDate!.day}/${task.dueDate!.month}',
                            style: TextStyle(
                              color: _getDueDateColor(task.dueDate!),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    // Show settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Theme'),
              subtitle: Text(
                context.watch<ThemeProvider>().themeModeString,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _toggleTheme(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification settings'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to notification settings
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (due.isBefore(today)) {
      return Colors.red.shade600; // Overdue
    } else if (due.isAtSameMomentAs(today)) {
      return Colors.orange.shade600; // Due today
    } else {
      return Colors.blue.shade600; // Future
    }
  }
} 