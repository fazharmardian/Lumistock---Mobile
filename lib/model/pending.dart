class Request {
  final int id;
  final int idUser;
  final int idItem;
  final int totalRequest;
  final String type;
  final DateTime requestDate;
  final String status;
  final DateTime? returnDate;
  final int? returnDays;

  final String userName;
  final int itemId;
  final String itemName;
  final String itemImage;
  final String itemDesc;

  Request({
    required this.id,
    required this.idUser,
    required this.idItem,
    required this.totalRequest,
    required this.type,
    required this.requestDate,
    required this.status,
    this.returnDate,
    this.returnDays,
    required this.userName,
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.itemDesc,
  });

  // Factory constructor to create an instance from JSON
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      idUser: json['id_user'],
      idItem: json['id_item'],
      totalRequest: json['total_request'],
      type: json['type'],
      requestDate: DateTime.parse(json['request_date']),
      status: json['status'],
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : null, // Safely parse or leave as null
      returnDays: json['must_return'] != null
          ? int.tryParse(json['must_return'].toString())
          : null, // Safely parse or leave as null
      userName: json['user']?['username'] ?? '',
      itemId: json['item']?['id'] ?? 0,
      itemName: json['item']?['name'] ?? '',
      itemImage: json['item']?['image'] ?? '',
      itemDesc: json['item']?['description'] ?? '',
    );
  }
}
