import 'package:flutter/foundation.dart';
import '../../data/models/item.dart';
import '../../data/models/unit.dart';
import '../../data/services/item_api_service.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemApiService _service;
  final String token;
  final int? companyId;

  List<Item> _items = [];
  List<Unit> _units = [];
  bool _loading = false;
  bool _saving = false;
  String? _error;
  String? _saveError;
  int _currentPage = 1;
  int _lastPage = 1;

  ItemViewModel({
    required ItemApiService service,
    required this.token,
    this.companyId,
  }) : _service = service;

  List<Item> get items => _items;
  List<Unit> get units => _units;
  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;
  String? get saveError => _saveError;
  bool get hasMore => _currentPage < _lastPage;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _currentPage = 1;
      final response = await _service.getItems(token, page: 1, companyId: companyId);
      _items = response.items;
      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!hasMore || _loading) return;
    try {
      final response = await _service.getItems(token, page: _currentPage + 1, companyId: companyId);
      _items.addAll(response.items);
      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUnits() async {
    try {
      _units = await _service.getUnits(token, companyId: companyId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createItem(Map<String, dynamic> data) async {
    _saving = true;
    _saveError = null;
    notifyListeners();
    try {
      await _service.createItem(token, data, companyId: companyId);
      _saving = false;
      notifyListeners();
      load();
      return true;
    } catch (e) {
      _saveError = e.toString();
      _saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await _service.deleteItems(token, [id], companyId: companyId);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
