class Bookmark {
  final int id;
  final int item;
  final int user;
  final String name;
  final int amount;
  final String image;
  final String description;

  Bookmark({
    required this.id,
    required this.item,
    required this.user,
    required this.name,
    required this.amount,
    required this.image,
    required this.description,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      item: json['item_id'],
      user: json['user_id'],
      name: json['item']?['name'],
      amount: json['item']?['amount'],
      image: json['item']?['image'],
      description: json['item']?['description'],
    );
  }
}
