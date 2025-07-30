import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';

class GroceryBudgetWidget extends StatefulWidget {
  final double? budgetLimit;
  final VoidCallback? onBudgetExceeded;

  const GroceryBudgetWidget({
    super.key,
    this.budgetLimit,
    this.onBudgetExceeded,
  });

  @override
  State<GroceryBudgetWidget> createState() => _GroceryBudgetWidgetState();
}

class _GroceryBudgetWidgetState extends State<GroceryBudgetWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _showBudgetInput = false;
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryProvider>(
      builder: (context, groceryProvider, child) {
        final totalSpent = groceryProvider.totalSpent;
        final totalBudget = groceryProvider.totalBudget;
        final remainingBudget = groceryProvider.remainingBudget;
        final budgetLimit = widget.budgetLimit ?? 0.0;
        
        // Calculate progress
        double progress = 0.0;
        if (budgetLimit > 0) {
          progress = (totalSpent / budgetLimit).clamp(0.0, 1.0);
        } else if (totalBudget > 0) {
          progress = (totalSpent / totalBudget).clamp(0.0, 1.0);
        }

        // Animate progress
        _progressController.value = progress;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showBudgetInput = !_showBudgetInput;
                        });
                      },
                      icon: Icon(
                        _showBudgetInput ? Icons.close : Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Budget input
                if (_showBudgetInput) ...[
                  _buildBudgetInput(),
                  const SizedBox(height: 16),
                ],
                
                // Progress bar
                _buildProgressBar(progress, totalSpent, budgetLimit > 0 ? budgetLimit : totalBudget),
                const SizedBox(height: 16),
                
                // Budget details
                _buildBudgetDetails(totalSpent, remainingBudget, budgetLimit),
                const SizedBox(height: 16),
                
                // Spending alerts
                if (budgetLimit > 0 && totalSpent > budgetLimit * 0.8) {
                  _buildSpendingAlert(totalSpent, budgetLimit),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Set Budget Limit',
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            final budget = double.tryParse(_budgetController.text);
            if (budget != null && budget > 0) {
              // TODO: Save budget limit to preferences
              setState(() {
                _showBudgetInput = false;
              });
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Set'),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, double spent, double total) {
    Color progressColor = Colors.green;
    if (progress > 0.8) {
      progressColor = Colors.orange;
    }
    if (progress > 1.0) {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spending Progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBudgetDetails(double spent, double remaining, double limit) {
    return Row(
      children: [
        Expanded(
          child: _buildBudgetCard(
            'Spent',
            '\$${spent.toStringAsFixed(2)}',
            Icons.shopping_cart,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBudgetCard(
            'Remaining',
            '\$${remaining.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.green,
          ),
        ),
        if (limit > 0) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildBudgetCard(
              'Limit',
              '\$${limit.toStringAsFixed(2)}',
              Icons.track_changes,
              Colors.blue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingAlert(double spent, double limit) {
    final percentage = (spent / limit * 100).toStringAsFixed(1);
    final isOverBudget = spent > limit;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverBudget ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverBudget ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverBudget ? Icons.warning : Icons.info,
            color: isOverBudget ? Colors.red : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOverBudget 
                ? 'You are \$${(spent - limit).toStringAsFixed(2)} over budget!'
                : 'You have used $percentage% of your budget',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOverBudget ? Colors.red : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 