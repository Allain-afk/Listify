import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/budget_settings.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  Currency _selectedCurrency = Currency.php;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentSettings();
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() {
    final budgetProvider = context.read<BudgetProvider>();
    if (budgetProvider.budgetSettings != null) {
      _budgetController.text = budgetProvider.budgetSettings!.budget.toString();
      _selectedCurrency = budgetProvider.budgetSettings!.currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Budget Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            if (budgetProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget Section
                    _buildBudgetSection(budgetProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Currency Section
                    _buildCurrencySection(budgetProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Actions Section
                    _buildActionsSection(budgetProvider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBudgetSection(BudgetProvider budgetProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Budget Amount',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Enter your budget',
                prefixText: budgetProvider.currencySymbol,
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Set your shopping budget to track your spending',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySection(BudgetProvider budgetProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.currency_exchange,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Currency',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Currency>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Select Currency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
                             items: Currency.values.map((currency) {
                 final settings = BudgetSettings(budget: 0.0, currency: currency);
                 return DropdownMenuItem<Currency>(
                   value: currency,
                   child: Row(
                     children: [
                       Text(settings.currencySymbol),
                       const SizedBox(width: 8),
                       Text(settings.currencyName),
                     ],
                   ),
                 );
               }).toList(),
              onChanged: (Currency? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCurrency = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred currency for budget tracking',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BudgetProvider budgetProvider) {
    return Column(
      children: [
        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveSettings(budgetProvider),
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Reset Budget Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _resetBudget(budgetProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Budget to Zero'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Remove Budget Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _removeBudget(budgetProvider),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove Budget'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  void _saveSettings(BudgetProvider budgetProvider) async {
    if (_formKey.currentState!.validate()) {
      final budget = double.parse(_budgetController.text);
      final settings = BudgetSettings(
        budget: budget,
        currency: _selectedCurrency,
      );
      
      await budgetProvider.saveBudgetSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget settings saved successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _resetBudget(BudgetProvider budgetProvider) async {
    final confirmed = await showDialog<bool>(
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
            'Reset Budget',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to reset your budget to zero?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade500,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await budgetProvider.resetBudget();
      _budgetController.text = '0.0';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget reset to zero'),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _removeBudget(BudgetProvider budgetProvider) async {
    final confirmed = await showDialog<bool>(
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
            'Remove Budget',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to remove your budget? This will disable budget tracking.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await budgetProvider.removeBudget();
      _budgetController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget removed'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
} 