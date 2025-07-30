import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../widgets/todo_item_card.dart';
import '../screens/task_details_screen.dart';
import '../screens/add_item_screen.dart';

class SwipeableTaskCard extends StatefulWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onUndoDelete;

  const SwipeableTaskCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    this.onUndoDelete,
  });

  @override
  State<SwipeableTaskCard> createState() => _SwipeableTaskCardState();
}

class _SwipeableTaskCardState extends State<SwipeableTaskCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  double _dragDistance = 0;
  bool _isDragging = false;
  static const double _swipeThreshold = 150.0; // Increased from 100.0
  static const double _velocityThreshold = 800.0; // Increased from 300.0

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Increased from 300ms
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98, // Less dramatic scale change
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    // Reset any ongoing animations
    _animationController.stop();
    _rotationController.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dx;
      
      // Reduce rotation sensitivity and cap the maximum rotation
      final rotationValue = (_dragDistance / 500).clamp(-0.05, 0.05); // Reduced from 300 and 0.1
      
      _rotationAnimation = Tween<double>(
        begin: 0.0,
        end: rotationValue,
      ).animate(CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOut,
      ));
      
      // Update rotation smoothly
      _rotationController.reset();
      _rotationController.forward();
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final velocity = details.velocity.pixelsPerSecond.dx;
    final absDragDistance = _dragDistance.abs();
    
    // More strict conditions for swiping
    final shouldSwipe = (absDragDistance > _swipeThreshold && velocity.abs() > 200) || 
                       velocity.abs() > _velocityThreshold;

    if (shouldSwipe) {
      if (_dragDistance > 0) {
        // Swipe right - View details
        _swipeRight();
      } else {
        // Swipe left - Delete
        _swipeLeft();
      }
    } else {
      // Snap back to center with gentle animation
      _resetPosition();
    }
  }

  void _swipeRight() {
    _slideAnimation = Tween<Offset>(
      begin: Offset(_dragDistance / MediaQuery.of(context).size.width, 0),
      end: const Offset(1.2, 0), // Reduced from 1.5 for smoother exit
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Changed from easeOut for smoother motion
    ));
    
    _animationController.forward().then((_) {
      _showTaskDetails();
      _resetPosition();
    });
  }

  void _swipeLeft() {
    _slideAnimation = Tween<Offset>(
      begin: Offset(_dragDistance / MediaQuery.of(context).size.width, 0),
      end: const Offset(-1.2, 0), // Reduced from -1.5 for smoother exit
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Changed from easeOut for smoother motion
    ));
    
    _animationController.forward().then((_) {
      widget.onDelete();
      _showUndoSnackBar();
      _resetPosition();
    });
  }

  void _resetPosition() {
    _slideAnimation = Tween<Offset>(
      begin: Offset(_dragDistance / MediaQuery.of(context).size.width, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // More gentle bounce-back animation
    ));
    
    // Also animate rotation back to 0
    _rotationAnimation = Tween<double>(
      begin: _rotationAnimation.value,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward().then((_) {
      setState(() {
        _dragDistance = 0;
      });
      _animationController.reset();
    });
    
    _rotationController.forward().then((_) {
      _rotationController.reset();
    });
  }

  void _showTaskDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(item: widget.item),
      ),
    );
  }

  void _showUndoSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${widget.item.title}" deleted'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: widget.onUndoDelete != null
            ? SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: widget.onUndoDelete!,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _editTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(item: widget.item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTap: _showTaskDetails,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _rotationController]),
        builder: (context, child) {
          final currentOffset = _isDragging
              ? Offset(_dragDistance / MediaQuery.of(context).size.width, 0)
              : _slideAnimation.value;

          return Stack(
            children: [
              // Swipe indicators
              if (_isDragging || _animationController.isAnimating)
                _buildSwipeIndicators(currentOffset),
              
              // Main card
              Transform.translate(
                offset: Offset(
                  currentOffset.dx * MediaQuery.of(context).size.width,
                  currentOffset.dy * MediaQuery.of(context).size.height,
                ),
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Transform.scale(
                    scale: _isDragging ? 1.01 : _scaleAnimation.value, // Reduced from 1.02
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isDragging
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08), // Reduced shadow
                                  blurRadius: 6, // Reduced from 8
                                  offset: const Offset(0, 3), // Reduced from (0, 4)
                                ),
                              ]
                            : null,
                      ),
                      child: TodoItemCard(
                        item: widget.item,
                        onToggle: widget.onToggle,
                        onEdit: _editTask,
                        showMenu: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwipeIndicators(Offset offset) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeProgress = (offset.dx.abs() * screenWidth / _swipeThreshold).clamp(0.0, 1.0);
    
    return Positioned.fill(
      child: Row(
        children: [
          // Left indicator (Delete)
          if (offset.dx < 0)
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: AnimatedOpacity(
                  opacity: swipeProgress * 0.8, // Reduced max opacity
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(10), // Reduced from 12
                    decoration: BoxDecoration(
                      color: Colors.red.shade500.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20, // Reduced from 24
                    ),
                  ),
                ),
              ),
            ),
          
          const Spacer(),
          
          // Right indicator (View Details)
          if (offset.dx > 0)
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: AnimatedOpacity(
                  opacity: swipeProgress * 0.8, // Reduced max opacity
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(10), // Reduced from 12
                    decoration: BoxDecoration(
                      color: Colors.blue.shade500.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 20, // Reduced from 24
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}