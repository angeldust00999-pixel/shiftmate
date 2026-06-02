class MenuModel {
  final int? id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String status;

  MenuModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'status': status,
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
      status: map['status'],
    );
  }
}
