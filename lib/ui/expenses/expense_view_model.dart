import 'package:flutter/material.dart';
import '../../data/models/expense.dart';
import '../../data/services/expense_api_service.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseApiService _service;
  final String token;
  final int? companyId;

  ExpenseViewModel({required ExpenseApiService service, required this.token, this.companyId})
      : _service = service;

  List<Expense> _expenses = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;

  List<Expense> get expenses => _expenses;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      _expenses = [];
      _currentPage = 1;
      _lastPage = 1;
      _loading = true;
    } else {
      _loadingMore = true;
    }
    _error = null;
    notifyListeners();
    try {
      final res = await _service.getExpenses(token, companyId: companyId, page: _currentPage);
      if (reset) {
        _expenses = res.expenses;
      } else {
        _expenses.addAll(res.expenses);
      }
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore) return;
    _currentPage++;
    await load(reset: false);
  }
}
