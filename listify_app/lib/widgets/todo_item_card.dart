import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';

class TodoItemCard extends StatefulWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final bool showMenu;

  const TodoItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    this.showMenu = false,
  });

  @override
  State<TodoItemCard> createState() => _TodoItemCardState();
}

class _TodoItemCardState extends State<TodoItemCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _completionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _completionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for tap feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Completion animation for check mark and color transition
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    ));

    // Color animation
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green.shade600,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeInOut,
    ));

    // Set initial state
    if (widget.item.isCompleted) {
      _completionController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TodoItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation state if completion status changed
    if (oldWidget.item.isCompleted != widget.item.isCompleted) {
      if (widget.item.isCompleted) {
        _completionController.forward();
      } else {
        _completionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Provide haptic feedback
    // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
    
    // Scale animation for visual feedback
    await _scaleController.forward();
    _scaleController.reverse();
    
    // Trigger the toggle
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Animated Checkbox
          GestureDetector(
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: Listenable.merge([_scaleAnimation, _completionAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.item.isCompleted
                            ? Colors.green.shade600
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      color: _colorAnimation.value,
                    ),
                    child: widget.item.isCompleted
                        ? Transform.scale(
                            scale: _completionAnimation.value,
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: widget.item.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                    color: widget.item.isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ) ?? const TextStyle(),
                  child: Text(widget.item.title),
                ),
                
                // Description (if exists)
                if (widget.item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: widget.item.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                      color: Theme.of(context).colorScheme.secondary,
                    ) ?? const TextStyle(),
                    child: Text(
                      widget.item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                
                // Meta info (priority, due date)
                if (widget.item.priority != Priority.medium || widget.item.dueDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Priority badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(widget.item.priority).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPriorityColor(widget.item.priority),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPriorityIcon(widget.item.priority),
                              size: 12,
                              color: _getPriorityColor(widget.item.priority),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getPriorityLabel(widget.item.priority),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getPriorityColor(widget.item.priority),
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Due date
                      if (widget.item.dueDate != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDueDateColor(widget.item.dueDate!).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getDueDateColor(widget.item.dueDate!),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: _getDueDateColor(widget.item.dueDate!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd').format(widget.item.dueDate!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getDueDateColor(widget.item.dueDate!),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Menu button (if enabled)
          if (widget.showMenu) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.secondary,
                size: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Theme.of(context).cardTheme.color,
              elevation: 4,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    widget.onEdit();
                    break;
                  case 'toggle':
                    _handleTap();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        widget.item.isCompleted ? Icons.undo : Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.item.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green.shade600;
      case Priority.medium:
        return Colors.amber.shade700;
      case Priority.high:
        return Colors.red.shade600;
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
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