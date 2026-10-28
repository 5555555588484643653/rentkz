import '../models/apartment.dart';
import '../repositories/apartment_repository.dart';

export '../repositories/apartment_repository.dart' show SortOrder;

/// Пәтерлермен жұмыс істейтін сервис қабаты.
/// UI тікелей Repository-мен сөйлеспей, осы сервис арқылы өтеді.
class ApartmentService {
  static final ApartmentService _instance = ApartmentService._internal();
  factory ApartmentService() => _instance;
  ApartmentService._internal();

  final ApartmentRepository _repo = ApartmentRepository();

  // ─── CREATE ───────────────────────────────────────────────────────────────

  Future<void> addApartment(Apartment apartment) => _repo.insertApartment(apartment);

  // ─── READ ─────────────────────────────────────────────────────────────────

  Future<List<Apartment>> getAllApartments() => _repo.getAllApartments();

  Future<Apartment?> getById(String id) => _repo.getApartmentById(id);

  Future<List<Apartment>> getFavorites() => _repo.getFavoriteApartments();

  Future<bool> isFavorite(String id) async {
    final apt = await _repo.getApartmentById(id);
    return apt?.isFavorite ?? false;
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updateApartment(Apartment apartment) => _repo.updateApartment(apartment);

  /// Таңдаулы күйін ауыстырады, жаңа күйді қайтарады
  Future<bool> toggleFavorite(String id) => _repo.toggleFavorite(id);

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<void> deleteApartment(String id) => _repo.deleteApartment(id);

  // ─── SEARCH / FILTER / SORT ───────────────────────────────────────────────

  Future<List<Apartment>> search({
    String query = '',
    int roomsFilter = 0,
    double maxPrice = 1000000,
    bool? onlyAvailable,
    SortOrder sortOrder = SortOrder.newest,
  }) {
    return _repo.searchAndFilter(
      query: query,
      roomsFilter: roomsFilter,
      maxPrice: maxPrice,
      onlyAvailable: onlyAvailable,
      sortOrder: sortOrder,
    );
  }
}
