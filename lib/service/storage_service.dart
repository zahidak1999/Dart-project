import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/shopping_list.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getListFile(String listId) async {
    final path = await _localPath;
    return File('$path/$listId.json');
  }

  Future<void> saveList(ShoppingList todoList) async {
    final file = await _getListFile(todoList.id);
    String jsonString = jsonEncode(todoList.toJson());
    await file.writeAsString(jsonString);
  }

  Future<ShoppingList?> loadList(String listId) async {
    try {
      final file = await _getListFile(listId);
      if (!await file.exists()) return null;
      String contents = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(contents);
      return ShoppingList.fromJson(jsonMap);
    } catch (e) {
      print("Error loading list: $e");
      return null;
    }
  }

  Future<List<ShoppingList>> loadAllLists() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      List<ShoppingList> lists = [];
      List<FileSystemEntity> files = directory.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          String contents = await file.readAsString();
          Map<String, dynamic> jsonMap = jsonDecode(contents);
          lists.add(ShoppingList.fromJson(jsonMap));
        }
      }
      return lists;
    } catch (e) {
      print("Error loading all lists: $e");
      return [];
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      final file = await _getListFile(listId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Error deleting list: $e");
    }
  }
}
