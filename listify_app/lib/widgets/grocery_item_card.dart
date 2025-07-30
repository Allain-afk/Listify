import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/grocery_item.dart';
import '../providers/budget_provider.dart';

class GroceryItemCard extends StatefulWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showMenu;

  const GroceryItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.showMenu = true,
  });

  @override
  State<GroceryItemCard> createState() => _GroceryItemCardState();
}

class _GroceryItemCardState extends State<GroceryItemCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _completionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _completionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: Colors.green,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeInOut,
    ));

    _completionController.value = widget.item.isCompleted ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(GroceryItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _scaleController.reverse();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => widget.onEdit(),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                  ),
                  SlidableAction(
                    onPressed: (context) => widget.onDelete(),
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: _handleTap,
                      child: AnimatedBuilder(
                        animation: _completionAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _colorAnimation.value,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.item.isCompleted
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: widget.item.isCompleted
                                  ? Transform.scale(
                                      scale: _completionAnimation.value,
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Item details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with strikethrough animation
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: widget.item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: widget.item.isCompleted
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface,
                            ) ?? const TextStyle(),
                            child: Text(widget.item.name),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Price and quantity info
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(widget.item.category).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getCategoryName(widget.item.category),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getCategoryColor(widget.item.category),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Qty: ${widget.item.quantity}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          
                          if (widget.item.notes?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.item.notes!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Price
                    Consumer<BudgetProvider>(
                      builder: (context, budgetProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              budgetProvider.formatAmount(widget.item.price),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: widget.item.isCompleted
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (widget.item.quantity > 1) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Total: ${budgetProvider.formatAmount(widget.item.totalPrice)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    
                    // Menu button
                    if (widget.showMenu) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              widget.onEdit();
                              break;
                            case 'delete':
                              widget.onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(GroceryCategory category) {
    switch (category) {
      case GroceryCategory.fruits:
        return Colors.orange;
      case GroceryCategory.vegetables:
        return Colors.green;
      case GroceryCategory.dairy:
        return Colors.blue;
      case GroceryCategory.meat:
        return Colors.red;
      case GroceryCategory.pantry:
        return Colors.brown;
      case GroceryCategory.beverages:
        return Colors.purple;
      case GroceryCategory.snacks:
        return Colors.yellow.shade700;
      case GroceryCategory.household:
        return Colors.grey;
      case GroceryCategory.other:
        return Colors.grey.shade600;
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