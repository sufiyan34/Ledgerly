import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsHistoryScreen> createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  String _searchQuery = '';
  String _selectedCategoryId = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.simpleCurrency(
      name: appState.profile.currency,
    );

    // Apply filters
    final filteredTxs = appState.transactions.where((tx) {
      final matchesSearch =
          tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.note.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategoryId == 'all' || tx.categoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();

    // Group transactions by date
    final groupedTxs = _groupTransactionsByDate(filteredTxs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Screen Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'Transactions History',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: TextFormField(
            style: const TextStyle(color: AppTheme.onSurface),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
              hintText: 'Search transactions...',
              hintStyle: const TextStyle(color: AppTheme.onSurfaceVariant),
              filled: true,
              fillColor: AppTheme.surfaceContainer,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Category Quick Filters (horizontal scroll)
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: appState.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final isSelected = isAll
                  ? _selectedCategoryId == 'all'
                  : _selectedCategoryId == appState.categories[index - 1].id;

              final label = isAll ? 'All' : appState.categories[index - 1].name;
              final color = isAll
                  ? AppTheme.primary
                  : appState.categories[index - 1].color;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = isAll
                        ? 'all'
                        : appState.categories[index - 1].id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : AppTheme.surfaceContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? color.withOpacity(0.4)
                          : AppTheme.primary.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!isAll) ...[
                        Icon(
                          appState.categories[index - 1].iconData,
                          size: 14,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? color
                              : AppTheme.onSurfaceVariant.withOpacity(0.8),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Transactions List
        Expanded(
          child: filteredTxs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No matching records found.',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                  itemCount: groupedTxs.keys.length,
                  itemBuilder: (context, keyIndex) {
                    final date = groupedTxs.keys.elementAt(keyIndex);
                    final txs = groupedTxs[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Group Date Header
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 8.0,
                            left: 4.0,
                          ),
                          child: Text(
                            _formatHeaderDate(date),
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        // List items inside group
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: txs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, txIndex) {
                            final tx = txs[txIndex];
                            final cat = appState.categories.firstWhere(
                              (c) => c.id == tx.categoryId,
                              orElse: () => Category(
                                id: 'unknown',
                                name: 'Other',
                                iconName: 'category',
                                color: AppTheme.outline,
                              ),
                            );

                            final isExpense =
                                tx.type == TransactionType.expense;
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
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: cat.color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        cat.iconData,
                                        color: cat.color,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (tx.note.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              tx.note,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppTheme.onSurfaceVariant
                                                    .withOpacity(0.6),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formattedAmount,
                                      style: TextStyle(
                                        color: isExpense
                                            ? AppTheme.error
                                            : AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> txs,
  ) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (var tx in txs) {
      final dateOnly = DateTime(
        tx.dateTime.year,
        tx.dateTime.month,
        tx.dateTime.day,
      );
      if (grouped[dateOnly] == null) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(tx);
    }
    return grouped;
  }

  String _formatHeaderDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dt == today) {
      return 'TODAY';
    } else if (dt == yesterday) {
      return 'YESTERDAY';
    } else {
      return DateFormat('EEEE, MMMM d, y').format(dt).toUpperCase();
    }
  }
}
