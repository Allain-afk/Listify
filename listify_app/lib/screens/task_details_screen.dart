import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import '../screens/add_item_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TodoItem item;

  const TaskDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and Priority Section
                    _buildStatusSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Title Section
                    _buildTitleSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Description Section
                    if (item.description.isNotEmpty) ...[
                      _buildDescriptionSection(context),
                      const SizedBox(height: 24),
                    ],
                    
                    // Dates Section
                    _buildDatesSection(context),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    _buildActionButtons(context),
                    
                    const SizedBox(height: 20),
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Task Details',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _editTask(context),
            icon: const Icon(Icons.edit_outlined, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          // Completion Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: item.isCompleted 
                  ? Colors.green.shade50 
                  : Colors.orange.shade50,
              border: Border.all(
                color: item.isCompleted 
                    ? Colors.green.shade200 
                    : Colors.orange.shade200,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.isCompleted ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: item.isCompleted 
                      ? Colors.green.shade700 
                      : Colors.orange.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  item.isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.isCompleted 
                        ? Colors.green.shade700 
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Priority Badge
          _buildPriorityBadge(context),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              decoration: item.isCompleted 
                  ? TextDecoration.lineThrough 
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              decoration: item.isCompleted 
                  ? TextDecoration.lineThrough 
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Created Date
          _buildDateRow(
            context,
            Icons.add_circle_outline,
            'Created',
            DateFormat('EEEE, MMM dd, yyyy \'at\' h:mm a').format(item.createdAt),
            Colors.blue.shade600,
          ),
          
          // Due Date
          if (item.dueDate != null) ...[
            const SizedBox(height: 12),
            _buildDateRow(
              context,
              Icons.event_outlined,
              'Due',
              DateFormat('EEEE, MMM dd, yyyy').format(item.dueDate!),
              _getDueDateColor(item.dueDate!),
            ),
          ],
          
          // Completed Date
          if (item.isCompleted && item.completedAt != null) ...[
            const SizedBox(height: 12),
            _buildDateRow(
              context,
              Icons.check_circle_outline,
              'Completed',
              DateFormat('EEEE, MMM dd, yyyy \'at\' h:mm a').format(item.completedAt!),
              Colors.green.shade600,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, IconData icon, String label, String date, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            date,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _editTask(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Task'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final color = _getPriorityColor(item.priority);
    final text = _getPriorityText(item.priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(item.priority),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _editTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(item: item),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade600;
      case Priority.medium:
        return Colors.orange.shade600;
      case Priority.low:
        return Colors.green.shade600;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'HIGH';
      case Priority.medium:
        return 'MEDIUM';
      case Priority.low:
        return 'LOW';
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Icons.arrow_upward;
      case Priority.medium:
        return Icons.remove;
      case Priority.low:
        return Icons.arrow_downward;
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red.shade600; // Overdue
    } else if (difference == 0) {
      return Colors.orange.shade600; // Due today
    } else if (difference <= 2) {
      return Colors.amber.shade700; // Due soon
    } else {
      return Colors.blue.shade600; // Future
    }
  }
}