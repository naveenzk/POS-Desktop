class ReceiptItem {
  final int id;
  final String itemName;
  int quantity;
  final double price;
  int product_id;

  ReceiptItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.product_id,
  });

  // get from db
  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      id: map['order_id'],
      itemName: map['product_name'],
      quantity: map['quantity'],
      price: map['price'],
      product_id: map['product_id'],
    );
  }

  // set to db
  Map<String, dynamic> toMap() {
    return {
      'product_name': itemName,
      'quantity': quantity,
      'price': price,
      'product_id': product_id,
    };
  }
}
