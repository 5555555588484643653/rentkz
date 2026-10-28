/// Пәтер моделі — SQLite-қа сәйкес toMap / fromMap әдістерімен
class Apartment {
  final String id;
  final String title;
  final String address;
  final String price;
  final double priceNum; // SQLite сұрыптауы үшін сандық баға
  final int roomsCount;
  final String rooms;
  final String area;
  final String floor;
  final String description;
  final List<String> amenities;
  final String imageUrl;
  final String ownerName;
  final String ownerPhone;
  final bool isLongTerm;
  final bool isAvailable;
  final bool isFavorite;
  final DateTime createdAt;

  const Apartment({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.priceNum,
    required this.roomsCount,
    required this.rooms,
    required this.area,
    required this.floor,
    required this.description,
    required this.amenities,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerPhone,
    this.isLongTerm = true,
    this.isAvailable = true,
    this.isFavorite = false,
    required this.createdAt,
  });

  /// SQLite Map -> Apartment
  factory Apartment.fromMap(Map<String, dynamic> map) {
    return Apartment(
      id: map['id'] as String,
      title: map['title'] as String,
      address: map['address'] as String,
      price: map['price'] as String,
      priceNum: (map['priceNum'] as num).toDouble(),
      roomsCount: map['roomsCount'] as int,
      rooms: map['rooms'] as String,
      area: map['area'] as String,
      floor: map['floor'] as String,
      description: map['description'] as String,
      amenities: (map['amenities'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      imageUrl: map['imageUrl'] as String? ?? '',
      ownerName: map['ownerName'] as String,
      ownerPhone: map['ownerPhone'] as String,
      isLongTerm: (map['isLongTerm'] as int) == 1,
      isAvailable: (map['isAvailable'] as int) == 1,
      isFavorite: (map['isFavorite'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Apartment -> SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'price': price,
      'priceNum': priceNum,
      'roomsCount': roomsCount,
      'rooms': rooms,
      'area': area,
      'floor': floor,
      'description': description,
      'amenities': amenities.join(','),
      'imageUrl': imageUrl,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'isLongTerm': isLongTerm ? 1 : 0,
      'isAvailable': isAvailable ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Өрістерді өзгерту үшін copyWith
  Apartment copyWith({
    String? id,
    String? title,
    String? address,
    String? price,
    double? priceNum,
    int? roomsCount,
    String? rooms,
    String? area,
    String? floor,
    String? description,
    List<String>? amenities,
    String? imageUrl,
    String? ownerName,
    String? ownerPhone,
    bool? isLongTerm,
    bool? isAvailable,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Apartment(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      price: price ?? this.price,
      priceNum: priceNum ?? this.priceNum,
      roomsCount: roomsCount ?? this.roomsCount,
      rooms: rooms ?? this.rooms,
      area: area ?? this.area,
      floor: floor ?? this.floor,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      isLongTerm: isLongTerm ?? this.isLongTerm,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
