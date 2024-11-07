class Lending {
  final int id;
  final int idUser;
  final int idItem;
  final int totalRequest;
  final DateTime lendDate;
  final DateTime returnDate;
  final DateTime? actualReturnDate;
  final String status;

  final String userName;

  final int itemId;
  final String itemName;
  final String itemImage;
  final String itemDesc;

  Lending({
    required this.id,
    required this.idUser,
    required this.idItem,
    required this.totalRequest,
    required this.lendDate,
    required this.returnDate,
    this.actualReturnDate,
    required this.status,
    required this.userName,
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.itemDesc,
  });

  factory Lending.fromJson(Map<String, dynamic> json) {
    return Lending(
      id: json['id'],
      idUser: json['id_user'],
      idItem: json['id_item'],
      totalRequest: json['total_request'],
      lendDate: DateTime.parse(json['lend_date']),
      returnDate: DateTime.parse(json['return_date']),
      actualReturnDate: json['actual_return_date'] != null
          ? DateTime.parse(json['actual_return_date'])
          : null,
      status: json['status'],
      userName: json['users']?['username'],
      itemId: json['items']?['id'],
      itemName: json['items']?['name'],
      itemImage: json['items']?['image'],
      itemDesc: json['items']?['description'],
    );
  }
}
