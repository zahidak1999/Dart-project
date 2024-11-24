// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/shopping_provider.dart';
import '../models/item.dart';
import '../models/shopping_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem(ShoppingProvider provider) {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      provider.addItem(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  void _showAddListDialog(ShoppingProvider provider) {
    TextEditingController listController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add New List'),
        content: TextField(
          controller: listController,
          decoration: InputDecoration(hintText: 'List Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String name = listController.text.trim();
              if (name.isNotEmpty) {
                provider.addList(name);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteListDialog(ShoppingProvider provider, ShoppingList list) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete List'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteList(list.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingProvider>(
      builder: (context, provider, child) {
        return DefaultTabController(
          length: provider.lists.isNotEmpty ? provider.lists.length : 1,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Shopping List'),
              bottom: provider.lists.isNotEmpty
                  ? TabBar(
                isScrollable: true,
                onTap: (index) {
                  provider.setCurrentList(provider.lists[index]);
                },
                tabs: provider.lists.map((list) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(list.name),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _showDeleteListDialog(provider, list);
                          },
                          child: Icon(
                            Icons.close,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
                  : null,
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _showAddListDialog(provider),
                ),
              ],
            ),
            body: provider.currentList == null
                ? Center(
              child: Text(
                'No list selected. Add a new list, or select from tab.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
                : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: 'Add new item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(provider),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      provider.reorderItems(oldIndex, newIndex);
                    },
                    children: provider.currentList!.items.map((item) {
                      return Container(
                        key: ValueKey(item.id),
                        color: item.isCompleted
                            ? Colors.green[50]
                            : Colors.white,
                        child: ListTile(
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item.isCompleted
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          trailing: item.isCompleted
                              ? Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                              : Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            bool wasCompleted = item.isCompleted;
                            provider.toggleItem(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  wasCompleted
                                      ? '"${item.title}" marked as not bought.'
                                      : '"${item.title}" marked as bought.',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
