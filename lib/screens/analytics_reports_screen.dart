import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class AnalyticsReportsScreen extends StatefulWidget {
  const AnalyticsReportsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsReportsScreen> createState() => _AnalyticsReportsScreenState();
}

class _AnalyticsReportsScreenState extends State<AnalyticsReportsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.simpleCurrency(
      name: appState.profile.currency,
    );

    // Calculate total expense
    final double totalExpenses = appState.monthlyExpense;

    // Get categories with positive expenses
    final Map<String, double> categorySpentMap = {};
    for (var cat in appState.categories) {
      final spent = appState.getCategorySpent(cat.id);
      if (spent > 0) {
        categorySpentMap[cat.id] = spent;
      }
    }

    final activeCategories =
        appState.categories
            .where((c) => categorySpentMap.containsKey(c.id))
            .toList()
          ..sort(
            (a, b) =>
                categorySpentMap[b.id]!.compareTo(categorySpentMap[a.id]!),
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics & Reports',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_input_component_outlined,
                  color: AppTheme.primary,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/budgeting-limits');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Summary Overview Card
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'TOTAL SPENT',
                      style: textTheme.labelMedium?.copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormat.format(totalExpenses),
                      style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: AppTheme.outlineVariant),
                Column(
                  children: [
                    Text(
                      'TOTAL INCOME',
                      style: textTheme.labelMedium?.copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormat.format(appState.monthlyIncome),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Spend Distribution Chart Header
          Text(
            'Spend Distribution',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Pie Chart
          if (activeCategories.isEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No expenses logged this month to analyze.',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else ...[
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 4,
                        centerSpaceRadius: 50,
                        sections: _getPieChartSections(
                          activeCategories,
                          categorySpentMap,
                          totalExpenses,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legends wrapping
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: activeCategories.map((cat) {
                      final spent = categorySpentMap[cat.id] ?? 0.0;
                      final percent = totalExpenses > 0
                          ? (spent / totalExpenses * 100).toStringAsFixed(0)
                          : '0';
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cat.color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${cat.name} ($percent%)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Category Breakdown list
            Text(
              'Category Breakdown',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeCategories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cat = activeCategories[index];
                final spent = categorySpentMap[cat.id] ?? 0.0;
                final percent = (spent / totalExpenses * 100).toStringAsFixed(
                  1,
                );

                return GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  borderRadius: 16,
                  bgOpacity: 0.5,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cat.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cat.iconData, color: cat.color, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Simple horizontal bar indicator
                            Stack(
                              children: [
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: spent / totalExpenses,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: cat.color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(spent),
                            style: const TextStyle(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$percent%',
                            style: TextStyle(
                              color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(
    List<Category> cats,
    Map<String, double> spentMap,
    double total,
  ) {
    return List.generate(cats.length, (index) {
      final cat = cats[index];
      final spent = spentMap[cat.id] ?? 0.0;
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percent = total > 0
          ? (spent / total * 100).toStringAsFixed(0)
          : '0';

      return PieChartSectionData(
        color: cat.color,
        value: spent,
        title: '$percent%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppTheme.onPrimary,
        ),
      );
    });
  }
}
