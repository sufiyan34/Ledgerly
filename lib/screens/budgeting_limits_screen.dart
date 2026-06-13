import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/category.dart';

class BudgetingLimitsScreen extends StatelessWidget {
  const BudgetingLimitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.simpleCurrency(
      name: appState.profile.currency,
    );

    // Calculate total budgeted amount across categories
    double totalCategoryBudget = 0.0;
    for (var cat in appState.categories) {
      if (cat.budgetLimit != null) {
        totalCategoryBudget += cat.budgetLimit!;
      }
    }

    // Filter categories that have budgets set
    final budgetedCategories = appState.categories
        .where((cat) => cat.budgetLimit != null)
        .toList();
    final nonBudgetedCategories = appState.categories
        .where((cat) => cat.budgetLimit == null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Budgeting & Limits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tap on a category card to update its budget limit.',
                  ),
                  backgroundColor: AppTheme.surfaceContainerHigh,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Global Monthly Limit Box
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    hasGlow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GLOBAL MONTHLY LIMIT',
                          style: textTheme.labelMedium?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currencyFormat.format(
                                appState.profile.monthlyLimit,
                              ),
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Spent: ${currencyFormat.format(appState.monthlyExpense)}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppTheme.onSurfaceVariant.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Slider to adjust monthly limit
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.primary,
                            inactiveTrackColor: AppTheme.outlineVariant,
                            thumbColor: AppTheme.primary,
                            overlayColor: AppTheme.primary.withOpacity(0.2),
                            trackHeight: 4.0,
                          ),
                          child: Slider(
                            value: appState.profile.monthlyLimit,
                            min: 500.0,
                            max: 10000.0,
                            divisions: 19,
                            onChanged: (val) async {
                              await appState.updateMonthlyLimit(val);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$500',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '\$10,000',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Category Budgets Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category Budgets',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${budgetedCategories.length} SET',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Budget progress list
                  if (budgetedCategories.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No category budgets set. Tap categories below to set limits.',
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: budgetedCategories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cat = budgetedCategories[index];
                        final spent = appState.getCategorySpent(cat.id);
                        final limit = cat.budgetLimit ?? 0.0;
                        final ratio = limit > 0 ? spent / limit : 0.0;
                        final percent = (ratio * 100).toStringAsFixed(0);

                        Color statusColor = AppTheme.primary;
                        if (ratio >= 1.0) {
                          statusColor = AppTheme.error;
                        } else if (ratio >= 0.8) {
                          statusColor = Colors.amber;
                        }

                        return GestureDetector(
                          onTap: () {
                            _showEditLimitDialog(context, appState, cat);
                          },
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 16,
                            bgOpacity: 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      cat.iconData,
                                      color: cat.color,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${currencyFormat.format(spent)} / ${currencyFormat.format(limit)}',
                                      style: TextStyle(
                                        color: ratio >= 1.0
                                            ? AppTheme.error
                                            : AppTheme.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress bar
                                Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: ratio > 1.0 ? 1.0 : ratio,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$percent% Used',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      ratio >= 1.0
                                          ? 'Over limit!'
                                          : '${currencyFormat.format(limit - spent)} left',
                                      style: TextStyle(
                                        color: ratio >= 1.0
                                            ? AppTheme.error
                                            : AppTheme.onSurfaceVariant
                                                  .withOpacity(0.5),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  if (nonBudgetedCategories.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Unbudgeted Categories',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: nonBudgetedCategories.map((cat) {
                        return ActionChip(
                          avatar: Icon(
                            cat.iconData,
                            color: cat.color,
                            size: 14,
                          ),
                          label: Text(cat.name),
                          backgroundColor: AppTheme.surfaceContainer
                              .withOpacity(0.4),
                          side: BorderSide(
                            color: AppTheme.primary.withOpacity(0.06),
                          ),
                          onPressed: () {
                            _showEditLimitDialog(context, appState, cat);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLimitDialog(
    BuildContext context,
    AppState state,
    Category cat,
  ) {
    final controller = TextEditingController(
      text: cat.budgetLimit != null ? cat.budgetLimit!.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: AppTheme.surfaceDim,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppTheme.primary.withOpacity(0.12)),
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Set Budget: ${cat.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Set a monthly spending limit for this category. Leave blank to remove budget.',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.money,
                      color: AppTheme.outline,
                    ),
                    hintText: 'e.g. 500',
                    hintStyle: const TextStyle(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final limitVal = double.tryParse(controller.text.trim());
                  await state.updateCategoryBudget(cat.id, limitVal);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
