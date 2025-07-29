import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'providers/item_provider.dart';
import 'models/todo_item.dart';
import 'screens/add_item_screen.dart';
import 'widgets/todo_item_card.dart';
import 'widgets/empty_state.dart';

class ListifyApp extends StatefulWidget {
  const ListifyApp({super.key});

  @override
  State<ListifyApp> createState() => _ListifyAppState();
}

class _ListifyAppState extends State<ListifyApp> {
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Listify'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<ItemProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear_completed':
                      provider.clearCompleted();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(context, provider);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'clear_completed',
                    child: Text('Clear Completed'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clear_all',
                    child: Text('Clear All'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, child) {
          if (itemProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (itemProvider.items.isEmpty) {
            return const EmptyState();
          }

          return Column(
            children: [
              // Statistics bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total',
                      itemProvider.items.length.toString(),
                      Icons.list_alt,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Completed',
                      itemProvider.completedCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Pending',
                      itemProvider.pendingCount.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              
              // Todo list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: itemProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = itemProvider.items[index];
                    return Slidable(
                      key: ValueKey(item.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => itemProvider.deleteItem(item.id),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                      child: TodoItemCard(
                        item: item,
                        onToggle: () => itemProvider.toggleItem(item.id),
                        onEdit: () => _editItem(context, item),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewItem(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
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

  void _editItem(BuildContext context, TodoItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(item: item),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, ItemProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Tasks'),
          content: const Text('Are you sure you want to delete all tasks? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.clearAll();
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}