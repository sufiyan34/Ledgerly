import 'package:flutter/material.dart';
import 'package:ledgerly/models/category.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.simpleCurrency(
      name: appState.profile.currency,
    );

    // Get latest 5 transactions
    final recentTransactions = appState.transactions.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Circular profile photo
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCDEZhxa1Xo04jzw_qGZ7JP4GkZf9iZOdNqE0O4yfEHbqpcGEeNLPBDAETJAdxu2fcMly9SbaNn89twYIp_psWM7Q0Zow5ONtEXVV1drN3Hp8XOCmwnEolQ7pAKcBlHcZ5VgNHW2Wgy0cl__ieNkSwFXW21u9eZI5oSEKoC_dl14dqPoiuZD8svseBOQthhdRUDEj0HnIzYYZ2UssszLafokMScqHZIcSyr952l69xzhXaVHhs5_EI305YEcbpQnac_0h0QxYCVsPk',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WELCOME BACK',
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appState.profile.name,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Notifications Button
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications.'),
                      backgroundColor: AppTheme.surfaceContainerHigh,
                    ),
                  );
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Total Balance Card
          GlassCard(
            borderRadius: 24,
            hasGlow: true,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currencyFormat.format(appState.totalBalance),
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Income & Expense Breakdown Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MONTHLY INCOME',
                              style: textTheme.labelMedium?.copyWith(
                                fontSize: 8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+${currencyFormat.format(appState.monthlyIncome)}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.error.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MONTHLY EXPENSE',
                              style: textTheme.labelMedium?.copyWith(
                                fontSize: 8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '-${currencyFormat.format(appState.monthlyExpense)}',
                              style: const TextStyle(
                                color: AppTheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Spending Trends Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Trends',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to reports tab (Tab index 2)
                  // Simply inform or link
                },
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Spending Trends Chart
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  barGroups: _getBarGroups(appState),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          final style = TextStyle(
                            color: value.toInt() == DateTime.now().weekday - 1
                                ? AppTheme.primary
                                : AppTheme.onSurfaceVariant.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight:
                                value.toInt() == DateTime.now().weekday - 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(days[value.toInt() % 7], style: style),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Recent Activity Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'LATEST ${recentTransactions.length} ITEMS',
                style: textTheme.labelMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recent Activity List
          if (recentTransactions.isEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No transactions found.',
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
              itemCount: recentTransactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = recentTransactions[index];
                final cat = appState.categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => Category(
                    id: 'unknown',
                    name: 'Other',
                    iconName: 'category',
                    color: AppTheme.outline,
                  ),
                );

                final isExpense = tx.type == TransactionType.expense;
                final formattedAmount =
                    '${isExpense ? "-" : "+"}${currencyFormat.format(tx.amount)}';

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/transaction-detail',
                      arguments: tx.id,
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    borderRadius: 16,
                    bgOpacity: 0.5,
                    child: Row(
                      children: [
                        // Category Icon Container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cat.iconData, color: cat.color),
                        ),
                        const SizedBox(width: 14),
                        // Title & Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tx.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceVariant.withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Amount & Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formattedAmount,
                              style: TextStyle(
                                color: isExpense
                                    ? AppTheme.error
                                    : AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateLabel(tx.dateTime),
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant.withOpacity(
                                  0.5,
                                ),
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
        ],
      ),
    );
  }

  // Pre-seed some spending numbers per day for visual completeness
  List<BarChartGroupData> _getBarGroups(AppState state) {
    final now = DateTime.now();
    final List<double> weeklySpend = [120, 240, 480, 180, 320, 150, 80];

    // Overlay real data if present
    for (int i = 0; i < 7; i++) {
      final targetDate = now.subtract(Duration(days: now.weekday - 1 - i));
      double sum = 0.0;
      for (var tx in state.transactions) {
        if (tx.type == TransactionType.expense &&
            tx.dateTime.day == targetDate.day &&
            tx.dateTime.month == targetDate.month &&
            tx.dateTime.year == targetDate.year) {
          sum += tx.amount;
        }
      }
      if (sum > 0) {
        weeklySpend[i] = sum;
      }
    }

    return List.generate(7, (index) {
      final val = weeklySpend[index];
      final isToday = index == now.weekday - 1;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: val,
            color: isToday
                ? AppTheme.primary
                : AppTheme.primary.withOpacity(0.2),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dt.year, dt.month, dt.day);

    if (checkDate == today) {
      return DateFormat('h:mm a').format(dt);
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, y').format(dt);
    }
  }
}
