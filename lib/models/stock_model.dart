class StockModel {
  final int? id;
  final String itemName;
  final int quantity;
  final String unit;
  final String updatedAt;

  StockModel({
    this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'updated_at': updatedAt,
    };
  }

  factory StockModel.fromMap(Map<String, dynamic> map) {
    return StockModel(
      id: map['id'],
      itemName: map['item_name'],
      quantity: map['quantity'],
      unit: map['unit'],
      updatedAt: map['updated_at'],
    );
  }
}
