import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default to the first category
    final state = Provider.of<AppState>(context, listen: false);
    if (state.categories.isNotEmpty) {
      _selectedCategoryId = state.categories.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: AppTheme.onPrimary,
              surface: AppTheme.surfaceDim,
              onSurface: AppTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null)
      return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppTheme.errorContainer,
        ),
      );
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);
    final tx = Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      dateTime: _selectedDate,
      note: _noteController.text.trim(),
      type: _type,
    );

    await state.addTransaction(tx);

    if (mounted) {
      Navigator.pop(context); // return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Transaction'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Type selector segment
                    GlassCard(
                      padding: const EdgeInsets.all(6),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              TransactionType.expense,
                              'EXPENSE',
                            ),
                          ),
                          Expanded(
                            child: _buildTypeButton(
                              TransactionType.income,
                              'INCOME',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount input field
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'AMOUNT (${state.profile.currency})',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceVariant.withOpacity(
                                  0.3,
                                ),
                              ),
                              border: InputBorder.none,
                              prefixIcon: Container(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  state.profile.currency,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter an amount';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category, Title, Date, Memo fields
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category selector
                          Text(
                            'CATEGORY',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            dropdownColor: AppTheme.surfaceDim,
                            style: const TextStyle(color: AppTheme.onSurface),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: state.categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      cat.iconData,
                                      color: cat.color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(cat.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCategoryId = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Title field
                          Text(
                            'TRANSACTION TITLE',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(color: AppTheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'e.g. Whole Foods Market',
                              hintStyle: const TextStyle(
                                color: AppTheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Date picker trigger
                          Text(
                            'DATE',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'EEEE, MMMM d, y',
                                    ).format(_selectedDate),
                                    style: const TextStyle(
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppTheme.outline,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description / Memo Field
                          Text(
                            'MEMO / NOTE (OPTIONAL)',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 2,
                            style: const TextStyle(color: AppTheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Add a description...',
                              hintStyle: const TextStyle(
                                color: AppTheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Save Button
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: const Text(
                          'SAVE TRANSACTION',
                          style: TextStyle(
                            color: AppTheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(TransactionType targetType, String label) {
    final isSelected = _type == targetType;
    final color = targetType == TransactionType.income
        ? AppTheme.primary
        : AppTheme.error;
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = targetType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.4), width: 1.0)
              : Border.all(color: Colors.transparent, width: 1.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
