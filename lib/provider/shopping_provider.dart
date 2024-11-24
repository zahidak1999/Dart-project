import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_list.dart';
import '../models/item.dart';
import '../service/storage_service.dart';

class ShoppingProvider with ChangeNotifier {
  List<ShoppingList> _lists = [];
  final StorageService _storageService = StorageService();

  ShoppingProvider() {
    loadLists();
  }

  List<ShoppingList> get lists => _lists;

  ShoppingList? _currentList;

  ShoppingList? get currentList => _currentList;

  void setCurrentList(ShoppingList list) {
    _currentList = list;
    notifyListeners();
  }

  Future<void> loadLists() async {
    _lists = await _storageService.loadAllLists();
    for (var list in _lists) {
      list.items.sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return 0;
      });
    }
    if (_lists.isNotEmpty) {
      _currentList = _lists.first;
    }
    notifyListeners();
  }

  Future<void> addList(String name) async {
    var uuid = Uuid();
    ShoppingList newList = ShoppingList(id: uuid.v4(), name: name, items: []);
    _lists.add(newList);
    await _storageService.saveList(newList);
    notifyListeners();
  }

  Future<void> deleteList(String id) async {
    _lists.removeWhere((list) => list.id == id);
    await _storageService.deleteList(id);
    if (_currentList?.id == id) {
      _currentList = _lists.isNotEmpty ? _lists.first : null;
    }
    notifyListeners();
  }

  Future<void> addItem(String title) async {
    if (_currentList == null) return;
    var uuid = Uuid();
    Item newItem = Item(id: uuid.v4(), title: title);
    _currentList!.items.insert(0, newItem);
    await _storageService.saveList(_currentList!);
    notifyListeners();
  }

  Future<void> toggleItem(String itemId) async {
    if (_currentList == null) return;
    int index = _currentList!.items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _currentList!.items[index].isCompleted = !_currentList!.items[index].isCompleted;
      // Reorder items: move completed items to the bottom
      _currentList!.items.sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return 0;
      });
      await _storageService.saveList(_currentList!);
      notifyListeners();
    }
  }

  Future<void> reorderItems(int oldIndex, int newIndex) async {
    if (_currentList == null) return;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _currentList!.items.removeAt(oldIndex);
    _currentList!.items.insert(newIndex, item);
    await _storageService.saveList(_currentList!);
    notifyListeners();
  }
}