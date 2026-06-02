class TransactionModel {
  final int? id;
  final int menuId;
  final int quantity;
  final int totalPrice;
  final String date;

  TransactionModel({
    this.id,
    required this.menuId,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menu_id': menuId,
      'quantity': quantity,
      'total_price': totalPrice,
      'date': date,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      menuId: map['menu_id'],
      quantity: map['quantity'],
      totalPrice: map['total_price'],
      date: map['date'],
    );
  }
}
