import 'package:flutter/material.dart';

class Category {
  final int id;
  final String name;
  final String? imagePath;

  Category({required this.id, required this.name, required this.imagePath});

  // get from db (no need)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      imagePath: map['image_path'],
    );
  }

  // set to db (no need)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'image_path': imagePath};
  }
}

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [
    Category(id: 1, name: "مٹھائیاں", imagePath: 'assets/images/sweets.png'),
    Category(
      id: 2,
      name: "سموسے پکوڑے",
      imagePath: 'assets/images/samosay.jpeg',
    ),
    Category(id: 3, name: "بسکٹ", imagePath: 'assets/images/biscuits.jpg'),
    Category(id: 4, name: "بریڈ", imagePath: 'assets/images/bread.jpg'),
    Category(id: 5, name: "اضافی", imagePath: 'assets/images/others.jpg'),

    // FOR HARD CODED ITEMS, FETCH FROM DB IF INSTRUCTED ELSE JUST USE THIS! :D
  ]; // list of categories

  int selectedIndex = 0; // index of the selected category

  List<Category> get categories => List.unmodifiable(
    _categories,
  ); // should be unmodifiable because we can't edit it anywhere except for db

  //Unnecessary
  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  //Unnecessary
  void removeCategory(int index) {
    _categories.removeAt(index);
    notifyListeners();
  }

  //Unnecessary
  void updateCategory(int index, Category category) {
    _categories[index] = category;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
