import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item.dart';

class GrocerySearchFilter extends StatefulWidget {
  final Function(List<GroceryItem>) onFilterChanged;
  final List<GroceryItem> allItems;

  const GrocerySearchFilter({
    super.key,
    required this.onFilterChanged,
    required this.allItems,
  });

  @override
  State<GrocerySearchFilter> createState() => _GrocerySearchFilterState();
}

class _GrocerySearchFilterState extends State<GrocerySearchFilter> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  GroceryCategory? _selectedCategory;
  bool? _selectedStatus;
  String _sortBy = 'created';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<GroceryItem> filteredItems = List.from(widget.allItems);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (item.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filteredItems = filteredItems.where((item) => item.category == _selectedCategory).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filteredItems = filteredItems.where((item) => item.isCompleted == _selectedStatus).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'created':
        filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'category':
        filteredItems.sort((a, b) => a.category.index.compareTo(b.category.index));
        break;
      case 'status':
        filteredItems.sort((a, b) => a.isCompleted.toString().compareTo(b.isCompleted.toString()));
        break;
    }

    widget.onFilterChanged(filteredItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search grocery items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: _showFilters 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // Filter options
        if (_showFilters) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Category filter
                _buildCategoryFilter(),
                const SizedBox(height: 16),
                
                // Status filter
                _buildStatusFilter(),
                const SizedBox(height: 16),
                
                // Sort options
                _buildSortOptions(),
                const SizedBox(height: 16),
                
                // Clear filters button
                _buildClearFiltersButton(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = null;
                });
                _applyFilters();
              },
            ),
            ...GroceryCategory.values.map((category) {
              return FilterChip(
                label: Text(_getCategoryName(category)),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                  _applyFilters();
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _selectedStatus == null,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = null;
                });
                _applyFilters();
              },
            ),
            FilterChip(
              label: const Text('Pending'),
              selected: _selectedStatus == false,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? false : null;
                });
                _applyFilters();
              },
            ),
            FilterChip(
              label: const Text('Completed'),
              selected: _selectedStatus == true,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? true : null;
                });
                _applyFilters();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton() {
    final hasActiveFilters = _selectedCategory != null || 
                           _selectedStatus != null || 
                           _searchQuery.isNotEmpty;

    if (!hasActiveFilters) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _searchController.clear();
            _searchQuery = '';
            _selectedCategory = null;
            _selectedStatus = null;
            _sortBy = 'created';
          });
          _applyFilters();
        },
        icon: const Icon(Icons.clear_all),
        label: const Text('Clear All Filters'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
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