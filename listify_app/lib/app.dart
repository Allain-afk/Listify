import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'providers/item_provider.dart';
import 'providers/theme_provider.dart';
import 'models/todo_item.dart';
import 'screens/add_item_screen.dart';
import 'screens/task_details_screen.dart';
import 'screens/widget_bar_screen.dart';
import 'widgets/todo_item_card.dart';
import 'widgets/empty_state.dart';

class ListifyApp extends StatefulWidget {
  const ListifyApp({super.key});

  @override
  State<ListifyApp> createState() => _ListifyAppState();
}

class _ListifyAppState extends State<ListifyApp> {
  final Map<String, TodoItem> _recentlyDeleted = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load items when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Main Task List
            Column(
              children: [
                // Custom header
                _buildHeader(),
                
                // Content area
                Expanded(
                  child: Consumer<ItemProvider>(
                    builder: (context, itemProvider, child) {
                      if (itemProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      if (itemProvider.items.isEmpty) {
                        return EmptyState(onAddTask: () => _addNewItem(context));
                      }

                      return Column(
                        children: [
                          // Statistics section
                          _buildStatsSection(itemProvider),
                          
                          // Task list
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              itemCount: itemProvider.items.length,
                              itemBuilder: (context, index) {
                                final item = itemProvider.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Slidable(
                                    key: ValueKey(item.id),
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) => _deleteItem(itemProvider, item),
                                          backgroundColor: Colors.red.shade600,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _showTaskDetails(item),
                                      child: TodoItemCard(
                                        item: item,
                                        onToggle: () => itemProvider.toggleItem(item.id),
                                        onEdit: () => _editTask(item),
                                        showMenu: true,
                                      ),
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
            
            // Widget Bar Screen
            const WidgetBarScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Widget Bar',
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 4),
        child: FloatingActionButton.extended(
          onPressed: () => _addNewItem(context),
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'Add Task',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          Text(
            'Listify',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          Consumer2<ItemProvider, ThemeProvider>(
            builder: (context, itemProvider, themeProvider, child) {
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
                    case 'widget_bar':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WidgetBarScreen(),
                        ),
                      );
                      break;
                    case 'theme':
                      themeProvider.toggleTheme();
                      break;
                    case 'clear_completed':
                      itemProvider.clearCompleted();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(context, itemProvider);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'widget_bar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.dashboard,
                          size: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Widget Bar',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          size: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Theme: ${themeProvider.themeModeString}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildStatsSection(ItemProvider provider) {
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              provider.items.length.toString(),
              Icons.format_list_bulleted,
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
              'Completed',
              provider.completedCount.toString(),
              Icons.check_circle,
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
              'Pending',
              provider.pendingCount.toString(),
              Icons.schedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _addNewItem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItemScreen(),
      ),
    );
  }

  void _showTaskDetails(TodoItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(item: item),
      ),
    );
  }

  void _editTask(TodoItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(item: item),
      ),
    );
  }

  void _deleteItem(ItemProvider provider, TodoItem item) {
    // Store the item for potential undo
    _recentlyDeleted[item.id] = item;
    
    // Remove from provider
    provider.deleteItem(item.id);
    
    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${item.title}" deleted'),
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

  void _undoDelete(ItemProvider provider, String itemId) {
    final item = _recentlyDeleted[itemId];
    if (item != null) {
      provider.addItem(item);
      _recentlyDeleted.remove(itemId);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${item.title}" restored'),
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

  void _showClearAllDialog(BuildContext context, ItemProvider provider) {
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
            'Clear All Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete all tasks? This action cannot be undone.',
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