import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';

class TodoItemCard extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const TodoItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Completion Checkbox
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.isCompleted 
                          ? _getPriorityColor(item.priority)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: item.isCompleted 
                        ? _getPriorityColor(item.priority)
                        : Colors.transparent,
                  ),
                  child: item.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Task Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: item.isCompleted 
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item.isCompleted 
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPriorityBadge(item.priority),
                      ],
                    ),
                    
                    // Description
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: item.isCompleted 
                              ? Colors.grey.shade500
                              : Colors.grey.shade700,
                          decoration: item.isCompleted 
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Meta information
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Creation date
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        
                        // Due date (if set)
                        if (item.dueDate != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.event,
                            size: 14,
                            color: _getDueDateColor(item.dueDate!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due ${DateFormat('MMM dd').format(item.dueDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDueDateColor(item.dueDate!),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        
                        const Spacer(),
                        
                        // Completion status
                        if (item.isCompleted && item.completedAt != null)
                          Text(
                            'Completed ${DateFormat('MMM dd').format(item.completedAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Edit indicator
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority) {
    final color = _getPriorityColor(priority);
    final text = _getPriorityText(priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'HIGH';
      case Priority.medium:
        return 'MED';
      case Priority.low:
        return 'LOW';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0) {
      return Colors.orange; // Due today
    } else if (difference <= 2) {
      return Colors.amber; // Due soon
    } else {
      return Colors.grey.shade600; // Future
    }
  }
}