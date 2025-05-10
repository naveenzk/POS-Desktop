import 'package:flutter/material.dart';
import 'package:pos_desktop/podos/receiptitem.dart';

class Receipt {
  final int id;
  final DateTime date;
  final List<ReceiptItem> items;
  final double totalAmount;

  Receipt({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
  });

  //get from db like this
  factory Receipt.fromMap(Map<String, dynamic> map, List<ReceiptItem> items) {
    return Receipt(
      id: map['order_id'],
      date: DateTime.parse(map['order_date']),
      items: items,
      totalAmount: map['total_amount'],
    );
  }

  // set to db like this
  Map<String, dynamic> toMap() {
    return {
      'order_id': id,
      'order_date': date.toIso8601String(),
      'total_amount': totalAmount,
    };
  }
}

class ReceiptProvider with ChangeNotifier {
  final List<ReceiptItem> _receiptItems = [];

  List<ReceiptItem> get receiptItems => List.unmodifiable(_receiptItems);

  void addItem(ReceiptItem item) {
    if (item.itemName.trim().isEmpty) return; // Do nothing if name is empty

    final existingItemIndex = _receiptItems.indexWhere(
      (receiptItem) => receiptItem.itemName == item.itemName,
    );

    if (existingItemIndex != -1) {
      // Item exists, update quantity
      _receiptItems[existingItemIndex].quantity++;
    } else {
      // Item does not exist, add new item
      _receiptItems.insert(0, item);
    }

    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (index < 0 || index >= _receiptItems.length)
      return; // Prevent out-of-bounds access
    if (newQuantity <= 0) {
      _receiptItems.removeAt(index);
    } else {
      _receiptItems[index].quantity = newQuantity;
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _receiptItems.removeAt(index);
    notifyListeners();
  }

  void clearReceipt() {
    _receiptItems.clear();
    notifyListeners();
  }

  double calculateTotalPrice() {
    return _receiptItems.fold(
      0,
      (total, item) => total + (item.price * item.quantity),
    );
  }
}
