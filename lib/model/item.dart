class Item {
  final int id;
  final String name;
  final String description;
  final int amount;
  final int categoryId;
  final String category;
  final String image;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.category,
    required this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      amount: json['amount'],
      categoryId: json['category_id'],
      category: json['category']?['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'image': image,
    };
  }
}
