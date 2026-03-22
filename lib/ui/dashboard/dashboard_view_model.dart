import 'package:flutter/material.dart';
import '../../data/models/dashboard.dart';
import '../../data/services/dashboard_api_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardApiService _service;
  final String token;
  final int? companyId;

  DashboardViewModel({required DashboardApiService service, required this.token, this.companyId})
      : _service = service;

  DashboardResponse? _data;
  bool _loading = false;
  bool _initialLoading = true; // First load (show full spinner)
  String? _error;

  DashboardResponse? get data => _data;
  bool get loading => _loading;
  bool get initialLoading => _initialLoading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.getDashboard(token, companyId: companyId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _initialLoading = false;
      notifyListeners();
    }
  }

  // Force refresh data (clears cache and reloads)
  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.getDashboard(token, companyId: companyId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
