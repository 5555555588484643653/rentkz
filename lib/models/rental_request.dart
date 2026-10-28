/// Жалға алу өтінімі моделі — SQLite-қа сәйкес
class RentalRequestModel {
  final String id;
  final String apartmentId;
  final String apartmentTitle;
  final String apartmentPrice;
  final String fullName;
  final String phone;
  final String moveDate;
  final String message;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime createdAt;

  RentalRequestModel({
    required this.id,
    required this.apartmentId,
    required this.apartmentTitle,
    required this.apartmentPrice,
    required this.fullName,
    required this.phone,
    required this.moveDate,
    this.message = '',
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// SQLite Map -> RentalRequestModel
  factory RentalRequestModel.fromMap(Map<String, dynamic> map) {
    return RentalRequestModel(
      id: map['id'] as String,
      apartmentId: map['apartmentId'] as String,
      apartmentTitle: map['apartmentTitle'] as String,
      apartmentPrice: map['apartmentPrice'] as String,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
      moveDate: map['moveDate'] as String,
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// RentalRequestModel -> SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'apartmentTitle': apartmentTitle,
      'apartmentPrice': apartmentPrice,
      'fullName': fullName,
      'phone': phone,
      'moveDate': moveDate,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'Қабылданды';
      case 'rejected':
        return 'Қабылданбады';
      default:
        return 'Қаралуда';
    }
  }
}
