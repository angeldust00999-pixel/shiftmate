class PositionModel {
  final int? id;
  final String name;
  final String description;
  final String createdAt;

  PositionModel({
    this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'],
    );
  }
}
