import 'package:flutter/foundation.dart';
import './expiryItem.dart';
import '../db/database_provider.dart';

class ExpiryItems with ChangeNotifier {
  List<ExpiryItem> _items = [];

  List<ExpiryItem> get items =>
      _items..sort((a, b) => a.expiryDate.isBefore(b.expiryDate) ? 0 : 1);

  Future<void> loadItems() async {
    _items = await DatabaseProvider.db.getItems();
    notifyListeners();
  }

  Future<void> addItem(ExpiryItem itm) async {
    await DatabaseProvider.db.insert(itm);
    _items.add(itm);
    notifyListeners();
  }

  Future<void> updateItem(ExpiryItem itm) async {
    await DatabaseProvider.db.update(itm.id, itm);
    final index = _items.indexWhere((el) => el.id == itm.id);
    _items[index] = itm;
    notifyListeners();
  }

  Future<int> deleteItem(String id) async {
    await DatabaseProvider.db.delete(id);
    final index = _items.indexWhere((el) => el.id == id);
    _items.removeWhere((el) => el.id == id);
    notifyListeners();
    return index;
  }

  int size() {
    return _items.length;
  }
}
