import 'package:flutter/foundation.dart';

class AppRefreshService extends ChangeNotifier {
  AppRefreshService._();

  static final AppRefreshService instance = AppRefreshService._();

  int _version = 0;
  int get version => _version;

  void notifyDataChanged() {
    _version++;
    notifyListeners();
  }
}
