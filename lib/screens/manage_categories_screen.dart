import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/category.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  Color _selectedColor = AppTheme.primary;
  String _selectedIconName = 'shopping_cart';

  final List<Color> _colors = [
    AppTheme.primary,
    AppTheme.tertiary,
    AppTheme.secondary,
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF6BFF8A), // Green
    const Color(0xFFFFB36B), // Orange
    const Color(0xFFFF6BD4), // Pink
    const Color(0xFFE8D0FF), // Lavender light
  ];

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'coffee', 'icon': Icons.coffee},
    {'name': 'payments', 'icon': Icons.payments},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'medical_services', 'icon': Icons.medical_services},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard},
    {'name': 'trending_up', 'icon': Icons.trending_up},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final state = Provider.of<AppState>(context, listen: false);
    final cat = Category(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      iconName: _selectedIconName,
      color: _selectedColor,
    );

    await state.addCategory(cat);
    _nameController.clear();
    setState(() {
      _selectedColor = AppTheme.primary;
      _selectedIconName = 'shopping_cart';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category created successfully.'),
          backgroundColor: AppTheme.surfaceContainerHigh,
        ),
      );
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
        title: const Text('Manage Categories'),
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
                  // Section: Create Category Form
                  Text(
                    'Create Category',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category Name Input
                          Text(
                            'CATEGORY NAME',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppTheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'e.g. Dining Out',
                              hintStyle: const TextStyle(
                                color: AppTheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a category name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Color Picker Row
                          Text(
                            'THEME COLOR',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _colors.length,
                              itemBuilder: (context, index) {
                                final color = _colors[index];
                                final isSelected = _selectedColor == color;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 2.0,
                                            )
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: color.withOpacity(0.4),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Icon Selection Grid
                          Text(
                            'CATEGORY ICON',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _availableIcons.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) {
                              final item = _availableIcons[index];
                              final isSelected =
                                  _selectedIconName == item['name'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIconName = item['name'];
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _selectedColor.withOpacity(0.15)
                                        : AppTheme.surfaceContainer.withOpacity(
                                            0.4,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? _selectedColor
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    item['icon'],
                                    color: isSelected
                                        ? _selectedColor
                                        : AppTheme.outline,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit Category
                          GestureDetector(
                            onTap: _saveCategory,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              alignment: Alignment.center,
                              child: const Text(
                                'CREATE CATEGORY',
                                style: TextStyle(
                                  color: AppTheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Section: Existing Categories List
                  Text(
                    'Existing Categories',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cat = state.categories[index];
                      // Don't show delete for core seeded categories to prevent issues
                      final isSystem =
                          cat.id == 'cat-groceries' ||
                          cat.id == 'cat-coffee' ||
                          cat.id == 'cat-salary' ||
                          cat.id == 'cat-rent';

                      return GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        borderRadius: 16,
                        bgOpacity: 0.4,
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
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
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            if (cat.budgetLimit != null)
                              Text(
                                'Limit: \$${cat.budgetLimit!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            if (!isSystem) ...[
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.error,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showDeleteCategoryConfirm(
                                    context,
                                    state,
                                    cat,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryConfirm(
    BuildContext context,
    AppState state,
    Category cat,
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
            title: const Text('Delete Category?'),
            content: Text(
              'Are you sure you want to delete "${cat.name}"? Transactions using this category will remain, but the category itself will be removed.',
              style: const TextStyle(color: AppTheme.onSurfaceVariant),
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
                  await state.deleteCategory(cat.id);
                  if (context.mounted) Navigator.pop(context);
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
