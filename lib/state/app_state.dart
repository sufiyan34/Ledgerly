import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/user_profile.dart';

class AppState extends ChangeNotifier {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  bool _isSynced = true;
  bool _isSecurityEnabled = false;

  UserProfile _profile = UserProfile(
    name: 'Alex Rivera',
    email: 'alex.rivera@ledgerly.com',
    currency: '\$',
    monthlyLimit: 3500.0,
  );

  List<Category> _categories = [];
  List<Transaction> _transactions = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSynced => _isSynced;
  bool get isSecurityEnabled => _isSecurityEnabled;
  UserProfile get profile => _profile;
  List<Category> get categories => _categories;
  List<Transaction> get transactions => _transactions;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load settings
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _isSynced = prefs.getBool('isSynced') ?? true;
      _isSecurityEnabled = prefs.getBool('isSecurityEnabled') ?? false;

      // Load Profile
      final profileStr = prefs.getString('profile');
      if (profileStr != null) {
        _profile = UserProfile.fromJson(jsonDecode(profileStr));
      }

      // Load Categories
      final catStr = prefs.getString('categories');
      if (catStr != null) {
        final List<dynamic> decoded = jsonDecode(catStr);
        _categories = decoded.map((e) => Category.fromJson(e)).toList();
      } else {
        _seedDefaultCategories();
      }

      // Load Transactions
      final txStr = prefs.getString('transactions');
      if (txStr != null) {
        final List<dynamic> decoded = jsonDecode(txStr);
        _transactions = decoded.map((e) => Transaction.fromJson(e)).toList();
      } else {
        _seedDefaultTransactions();
      }
    } catch (e) {
      debugPrint("Error loading state: $e");
      _seedDefaultCategories();
      _seedDefaultTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _seedDefaultCategories() {
    _categories = [
      Category(
        id: 'cat-groceries',
        name: 'Groceries',
        iconName: 'shopping_cart',
        color: const Color(0xFF7DD3FC),
        budgetLimit: 600.0,
      ),
      Category(
        id: 'cat-coffee',
        name: 'Coffee & Drinks',
        iconName: 'coffee',
        color: const Color(0xFFC8A0F0),
        budgetLimit: 120.0,
      ),
      Category(
        id: 'cat-salary',
        name: 'Salary',
        iconName: 'payments',
        color: const Color(0xFF88B4CC),
      ),
      Category(
        id: 'cat-rent',
        name: 'Rent',
        iconName: 'home',
        color: const Color(0xFF88B4CC),
        budgetLimit: 2000.0,
      ),
      Category(
        id: 'cat-entertainment',
        name: 'Entertainment',
        iconName: 'movie',
        color: const Color(0xFFC8A0F0),
        budgetLimit: 250.0,
      ),
      Category(
        id: 'cat-transport',
        name: 'Transport',
        iconName: 'directions_car',
        color: const Color(0xFF7DD3FC),
        budgetLimit: 150.0,
      ),
    ];
    _saveCategories();
  }

  void _seedDefaultTransactions() {
    final now = DateTime.now();
    _transactions = [
      Transaction(
        id: 'tx-1',
        title: 'Whole Foods Market',
        amount: 124.50,
        categoryId: 'cat-groceries',
        dateTime: now.subtract(const Duration(hours: 2)),
        note: 'Weekly grocery shopping, fresh items.',
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx-2',
        title: 'Starbucks Central Park',
        amount: 12.80,
        categoryId: 'cat-coffee',
        dateTime: now.subtract(const Duration(hours: 5)),
        note: 'Double Espresso and pastry.',
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx-3',
        title: 'TechCorp Salary',
        amount: 4200.00,
        categoryId: 'cat-salary',
        dateTime: now.subtract(const Duration(days: 1)),
        note: 'Monthly base salary payout.',
        type: TransactionType.income,
      ),
      Transaction(
        id: 'tx-4',
        title: 'Skyline Rent Payment',
        amount: 1850.00,
        categoryId: 'cat-rent',
        dateTime: DateTime(now.year, now.month, 1),
        note: 'Monthly rental for apartment 4B.',
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx-5',
        title: 'Netflix Premium Plan',
        amount: 19.99,
        categoryId: 'cat-entertainment',
        dateTime: DateTime(
          now.year,
          now.month,
          1,
        ).subtract(const Duration(days: 1)),
        note: 'Shared account subscription.',
        type: TransactionType.expense,
      ),
    ];
    _saveTransactions();
  }

  // Setters & Actions
  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoggedIn = true;
    _profile = _profile.copyWith(email: email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('profile', jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password) async {
    _isLoggedIn = true;
    _profile = UserProfile(name: name, email: email, monthlyLimit: 3500.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('profile', jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    _profile = _profile.copyWith(name: name, email: email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateMonthlyLimit(double limit) async {
    _profile = _profile.copyWith(monthlyLimit: limit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> toggleSync(bool val) async {
    _isSynced = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSynced', val);
    notifyListeners();
  }

  Future<void> toggleSecurity(bool val) async {
    _isSecurityEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSecurityEnabled', val);
    notifyListeners();
  }

  // Transactions CRUD
  Future<void> addTransaction(Transaction tx) async {
    _transactions.insert(0, tx);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  // Categories CRUD
  Future<void> addCategory(Category cat) async {
    _categories.add(cat);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> updateCategoryBudget(String id, double? limit) async {
    final idx = _categories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _categories[idx] = _categories[idx].copyWith(budgetLimit: limit);
      await _saveCategories();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    // Move transactions under deleted category to "Uncategorized" or remove
    // (Here, we just keep them, but in real apps we handle ref integrity)
    await _saveCategories();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _transactions.clear();
    _categories.clear();
    _seedDefaultCategories();
    _seedDefaultTransactions();
    _profile = UserProfile(
      name: 'Alex Rivera',
      email: 'alex.rivera@ledgerly.com',
      monthlyLimit: 3500.0,
    );
    _isSynced = true;
    _isSecurityEnabled = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile');
    await prefs.remove('categories');
    await prefs.remove('transactions');
    await prefs.setBool('isSynced', true);
    await prefs.setBool('isSecurityEnabled', false);
    notifyListeners();
  }

  // Persistence helpers
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _transactions.map((e) => e.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(list));
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _categories.map((e) => e.toJson()).toList();
    await prefs.setString('categories', jsonEncode(list));
  }

  // Computed state calculations
  double get totalBalance {
    double balance = 0.0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  double get monthlyIncome {
    double total = 0.0;
    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income &&
          tx.dateTime.month == now.month &&
          tx.dateTime.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  double get monthlyExpense {
    double total = 0.0;
    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.type == TransactionType.expense &&
          tx.dateTime.month == now.month &&
          tx.dateTime.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  double getCategorySpent(String catId) {
    double spent = 0.0;
    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.categoryId == catId &&
          tx.type == TransactionType.expense &&
          tx.dateTime.month == now.month &&
          tx.dateTime.year == now.year) {
        spent += tx.amount;
      }
    }
    return spent;
  }
}
