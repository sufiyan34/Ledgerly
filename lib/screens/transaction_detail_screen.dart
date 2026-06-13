import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final txId = ModalRoute.of(context)!.settings.arguments as String;
    final appState = Provider.of<AppState>(context);
    final textTheme = Theme.of(context).textTheme;

    // Find transaction
    final tx = appState.transactions.firstWhere(
      (t) => t.id == txId,
      orElse: () => Transaction(
        id: 'notfound',
        title: 'Not Found',
        amount: 0.0,
        categoryId: '',
        dateTime: DateTime.now(),
        type: TransactionType.expense,
      ),
    );

    if (tx.id == 'notfound') {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('Transaction not found.')),
      );
    }

    final cat = appState.categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => Category(
        id: 'unknown',
        name: 'Other',
        iconName: 'category',
        color: AppTheme.outline,
      ),
    );

    final currencyFormat = NumberFormat.simpleCurrency(
      name: appState.profile.currency,
    );
    final isExpense = tx.type == TransactionType.expense;
    final formattedAmount =
        '${isExpense ? "-" : "+"}${currencyFormat.format(tx.amount)}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transaction Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () {
              _showDeleteConfirmDialog(context, appState, tx);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Theme Background Gradient
          Container(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Category visual card
                  Center(
                    child: Column(
                      children: [
                        // Large category circle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cat.color.withOpacity(0.12),
                            border: Border.all(
                              color: cat.color.withOpacity(0.3),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(cat.iconData, color: cat.color, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          cat.name.toUpperCase(),
                          style: textTheme.labelMedium?.copyWith(
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                            color: cat.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tx.title,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formattedAmount,
                          style: TextStyle(
                            color: isExpense
                                ? AppTheme.error
                                : AppTheme.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Detail blocks
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDetailItem(
                          textTheme,
                          'TRANSACTION TYPE',
                          isExpense ? 'Expense' : 'Income',
                          isExpense ? AppTheme.error : AppTheme.primary,
                        ),
                        const Divider(
                          color: AppTheme.outlineVariant,
                          height: 28,
                        ),
                        _buildDetailItem(
                          textTheme,
                          'DATE & TIME',
                          DateFormat(
                            'EEEE, MMMM d, y • h:mm a',
                          ).format(tx.dateTime),
                          AppTheme.onSurface,
                        ),
                        const Divider(
                          color: AppTheme.outlineVariant,
                          height: 28,
                        ),
                        _buildDetailItem(
                          textTheme,
                          'MEMO / NOTES',
                          tx.note.isEmpty ? 'No notes provided.' : tx.note,
                          tx.note.isEmpty
                              ? AppTheme.onSurfaceVariant.withOpacity(0.4)
                              : AppTheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: GlassCard(
                      borderRadius: 14,
                      bgOpacity: 0.8,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'BACK',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    TextTheme textTheme,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceVariant.withOpacity(0.5),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    AppState state,
    Transaction tx,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: AppTheme.surfaceDim,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.primary.withOpacity(0.12)),
            ),
            title: const Text('Delete Transaction?'),
            content: const Text(
              'Are you sure you want to permanently delete this financial record? This cannot be undone.',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
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
                  await state.deleteTransaction(tx.id);
                  if (context.mounted) {
                    Navigator.pop(context); // Pop dialog
                    Navigator.pop(context); // Pop screen
                  }
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(
                    color: AppTheme.error,
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
