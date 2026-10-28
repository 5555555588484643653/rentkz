import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/rental_request.dart';

/// Жалға алу өтінімдерімен жұмыс істейтін Repository қабаты
class RentalRequestRepository {
  final DatabaseHelper _db = DatabaseHelper();

  // ─── CREATE ───────────────────────────────────────────────────────────────

  Future<void> insertRequest(RentalRequestModel request) async {
    try {
      final db = await _db.database;
      await db.insert(
        'rental_requests',
        request.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Өтінім қосу кезінде қате: $e');
    }
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  Future<List<RentalRequestModel>> getAllRequests() async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'rental_requests',
        orderBy: 'createdAt DESC',
      );
      return maps.map((m) => RentalRequestModel.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Өтінімдерді оқу кезінде қате: $e');
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updateRequestStatus(String id, String status) async {
    try {
      final db = await _db.database;
      await db.update(
        'rental_requests',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Өтінім жаңарту кезінде қате: $e');
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<void> deleteRequest(String id) async {
    try {
      final db = await _db.database;
      await db.delete(
        'rental_requests',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Өтінімді өшіру кезінде қате: $e');
    }
  }
}

