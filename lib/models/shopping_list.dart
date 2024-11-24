import 'item.dart';

class ShoppingList {
  String id;
  String name;
  List<Item> items;

  ShoppingList({required this.id, required this.name, required this.items});

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<Item> itemObjs = itemsList.map((i) => Item.fromJson(i)).toList();

    return ShoppingList(
      id: json['id'],
      name: json['name'],
      items: itemObjs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((item) => item.toJson()).toList(),
  };
}