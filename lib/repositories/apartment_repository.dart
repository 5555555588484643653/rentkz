import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/apartment.dart';

/// Пәтер деректерімен жұмыс істейтін Repository қабаты.
/// CRUD, іздеу, сүзгілеу, сұрыптау және таңдаулылар операцияларын қамтиды.
class ApartmentRepository {
  final DatabaseHelper _db = DatabaseHelper();

  // ─── CREATE ──────────────────────────────────────────────────────────────

  /// Жаңа пәтер жазбасын қосу
  Future<void> insertApartment(Apartment apartment) async {
    try {
      final db = await _db.database;
      await db.insert(
        'apartments',
        apartment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Пәтер қосу кезінде қате: $e');
    }
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Барлық пәтерлерді оқу
  Future<List<Apartment>> getAllApartments() async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'apartments',
        orderBy: 'createdAt DESC',
      );
      return maps.map((m) => Apartment.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Пәтерлерді оқу кезінде қате: $e');
    }
  }

  /// ID бойынша бір пәтерді оқу
  Future<Apartment?> getApartmentById(String id) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'apartments',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Apartment.fromMap(maps.first);
    } catch (e) {
      throw Exception('Пәтерді оқу кезінде қате: $e');
    }
  }

  /// Таңдаулы пәтерлерді оқу
  Future<List<Apartment>> getFavoriteApartments() async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'apartments',
        where: 'isFavorite = ?',
        whereArgs: [1],
        orderBy: 'createdAt DESC',
      );
      return maps.map((m) => Apartment.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Таңдаулыларды оқу кезінде қате: $e');
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Пәтер жазбасын жаңарту
  Future<void> updateApartment(Apartment apartment) async {
    try {
      final db = await _db.database;
      await db.update(
        'apartments',
        apartment.toMap(),
        where: 'id = ?',
        whereArgs: [apartment.id],
      );
    } catch (e) {
      throw Exception('Пәтерді жаңарту кезінде қате: $e');
    }
  }

  /// Таңдаулы күйін ауыстыру (toggle)
  Future<bool> toggleFavorite(String id) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'apartments',
        columns: ['isFavorite'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return false;
      final current = (maps.first['isFavorite'] as int) == 1;
      await db.update(
        'apartments',
        {'isFavorite': current ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return !current; // Жаңа күй
    } catch (e) {
      throw Exception('Таңдаулы ауыстыру кезінде қате: $e');
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Пәтерді өшіру
  Future<void> deleteApartment(String id) async {
    try {
      final db = await _db.database;
      await db.delete(
        'apartments',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Пәтерді өшіру кезінде қате: $e');
    }
  }

  // ─── SEARCH & FILTER & SORT ───────────────────────────────────────────────

  /// Іздеу, сүзгілеу және сұрыптау (барлық параметрлер қосымша)
  Future<List<Apartment>> searchAndFilter({
    String query = '',
    int roomsFilter = 0,     // 0 = Барлығы
    double maxPrice = 1000000,
    bool? onlyFavorites,
    bool? onlyAvailable,
    SortOrder sortOrder = SortOrder.newest,
  }) async {
    try {
      final db = await _db.database;

      // SQL ORDER BY анықтау
      String orderBy;
      switch (sortOrder) {
        case SortOrder.priceAsc:
          orderBy = 'priceNum ASC';
          break;
        case SortOrder.priceDesc:
          orderBy = 'priceNum DESC';
          break;
        case SortOrder.areaAsc:
          orderBy = 'CAST(REPLACE(area, " м²", "") AS REAL) ASC';
          break;
        case SortOrder.areaDesc:
          orderBy = 'CAST(REPLACE(area, " м²", "") AS REAL) DESC';
          break;
        case SortOrder.oldest:
          orderBy = 'createdAt ASC';
          break;
        case SortOrder.newest:
        default:
          orderBy = 'createdAt DESC';
      }

      // WHERE шарттары
      final conditions = <String>[];
      final args = <dynamic>[];

      if (query.isNotEmpty) {
        conditions.add('(title LIKE ? OR address LIKE ? OR rooms LIKE ?)');
        final pattern = '%$query%';
        args.addAll([pattern, pattern, pattern]);
      }

      if (roomsFilter == 1) {
        conditions.add('roomsCount = ?');
        args.add(1);
      } else if (roomsFilter == 2) {
        conditions.add('roomsCount = ?');
        args.add(2);
      } else if (roomsFilter >= 3) {
        conditions.add('roomsCount >= ?');
        args.add(3);
      }

      conditions.add('priceNum <= ?');
      args.add(maxPrice);

      if (onlyFavorites == true) {
        conditions.add('isFavorite = 1');
      }

      if (onlyAvailable == true) {
        conditions.add('isAvailable = 1');
      }

      final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

      final maps = await db.query(
        'apartments',
        where: where,
        whereArgs: args.isNotEmpty ? args : null,
        orderBy: orderBy,
      );

      return maps.map((m) => Apartment.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Іздеу кезінде қате: $e');
    }
  }
}

/// Сұрыптау тәртібі
enum SortOrder {
  newest,    // Жаңадан ескіге
  oldest,    // Ескіден жаңаға
  priceAsc,  // Баға: арзандан
  priceDesc, // Баға: қымбаттан
  areaAsc,   // Ауданы: кіші
  areaDesc,  // Ауданы: үлкен
}

