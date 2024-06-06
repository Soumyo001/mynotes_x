import 'package:flutter/material.dart';
import 'package:mynotes_x/utilities/constants.dart';

class ListNotifier with ChangeNotifier {
  List<Map<dynamic, dynamic>> _items = [];

  List<Map<dynamic, dynamic>> get items => _items;

  void addItem(Map<dynamic, dynamic> item) {
    if (!_items.contains(item)) {
      _items.add(item);
      notifyListeners();
    }
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  void removeUnCheckedItems() {
    _items.removeWhere((element) => element[checkedTag] == false);
    notifyListeners();
  }

  void removeItem(Map<dynamic, dynamic> item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateItem(int index, Map<dynamic, dynamic> newItem) {
    if (index >= 0 && index < _items.length) {
      _items[index] = newItem;
      notifyListeners();
    }
  }

  void reload(List<Map<dynamic, dynamic>> value) {
    _items.clear();
    _items = value.where((element) => element[checkedTag] == true).toList();
    notifyListeners();
  }
}
