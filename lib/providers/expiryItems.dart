import 'package:flutter/foundation.dart';
import './expiryItem.dart';
import '../db/database_provider.dart';

class ExpiryItems with ChangeNotifier {
  List<ExpiryItem> _items = [];

  List<ExpiryItem> get items => _items
    ..sort((a, b) => a.expiryDate.isBefore(b.expiryDate)
        ? -1
        : a.expiryDate.isAfter(b.expiryDate)
            ? 1
            : 0);

  Future<void> loadItems() async {
    _items = await DatabaseProvider.db.getItems();
    notifyListeners();
  }

  Future<int> addItem(ExpiryItem itm) async {
    final item = await DatabaseProvider.db.insert(itm);
    _items.add(item);
    notifyListeners();
    return item.id;
  }

  Future<void> updateItem(ExpiryItem itm) async {
    await DatabaseProvider.db.update(itm.id, itm);
    final index = _items.indexWhere((el) => el.id == itm.id);
    _items[index] = itm;
    notifyListeners();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseProvider.db.delete(id);
    _items.removeWhere((el) => el.id == id);
    notifyListeners();
  }

  int size() {
    return _items.length;
  }
}
