import 'package:flutter/material.dart';
import 'package:pos_desktop/db/database_helper.dart';

class MenuItem {
  final int product_id;
  final String product_name;
  final double price;
  final int category_id;
  final String category_name;
  final String? imagePath;

  MenuItem({
    required this.product_id,
    required this.product_name,
    required this.price,
    required this.category_id,
    required this.category_name,
    this.imagePath,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      product_id: map['product_id'] as int,
      product_name: map['product_name'] as String,
      price: (map['price'] as num).toDouble(),
      category_id: map['category_id'] as int,
      category_name: map['category_name'] as String? ?? 'Uncategorized',
      imagePath: map['image_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': product_id,
      'product_name': product_name,
      'price': price,
      'category_id': category_id,
      'image_path': imagePath,
    };
  }
}

class MenuItemProvider with ChangeNotifier {
  List<MenuItem> _allMenuItems = [];
  late List<MenuItem> _menuItems;

  MenuItemProvider() {
    _menuItems = [];
    loadAllMenuItems(); // Initialize with database data
  }

  // Fetch all menu items from database
  Future<void> loadAllMenuItems() async {
    try {
      final dbHelper = DatabaseHelper();
      final List<Map<String, dynamic>> menuData =
          await dbHelper.fetchMenuItems();

      _allMenuItems = menuData.map((item) => MenuItem.fromMap(item)).toList();
      _menuItems = List.from(_allMenuItems);
      notifyListeners();
    } catch (e) {
      print("Error loading menu items: $e");
      // Fallback to empty lists
      _allMenuItems = [];
      _menuItems = [];
    }
    loadMenuItems(1);
  }

  // Fetch items by category from database
  Future<void> loadMenuItems(int categoryId) async {
    try {
      final dbHelper = DatabaseHelper();
      final List<Map<String, dynamic>> menuData = await dbHelper
          .fetchMenuItemsByCategory(categoryId);

      _menuItems = menuData.map((item) => MenuItem.fromMap(item)).toList();
      notifyListeners();
    } catch (e) {
      print("Error loading category items: $e");
      // Fallback to filtering existing items
      _menuItems =
          _allMenuItems
              .where((item) => item.category_id == categoryId)
              .toList();
      notifyListeners();
    }
  }

  // Admin-only functions
  Future<List<Map<String, List<MenuItem>>>> loadAllMenuItemsFromDB() async {
    await loadAllMenuItems(); // Refresh data first

    // Group by category (for admin interface)
    final Map<int, List<MenuItem>> grouped = {};
    for (var item in _allMenuItems) {
      grouped.putIfAbsent(item.category_id, () => []).add(item);
    }

    return grouped.entries.map((e) => {e.key.toString(): e.value}).toList();
  }

  // CRUD Operations
  void addMenuItem(MenuItem item) {
    _menuItems.add(item);
    _allMenuItems.add(item);
    notifyListeners();
  }

  void removeMenuItem(int index) {
    final item = _menuItems[index];
    _menuItems.removeAt(index);
    _allMenuItems.removeWhere((i) => i.product_id == item.product_id);
    notifyListeners();
  }

  void updateMenuItem(int index, MenuItem item) {
    _menuItems[index] = item;
    // Also update in master list
    final masterIndex = _allMenuItems.indexWhere(
      (i) => i.product_id == item.product_id,
    );
    if (masterIndex != -1) {
      _allMenuItems[masterIndex] = item;
    }
    notifyListeners();
  }

  // Getters
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
  List<MenuItem> get allMenuItems => List.unmodifiable(_allMenuItems);
}
