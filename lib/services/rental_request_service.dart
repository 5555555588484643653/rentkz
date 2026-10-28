import '../models/rental_request.dart';
import '../repositories/rental_request_repository.dart';

/// Жалға алу өтінімдерімен жұмыс істейтін сервис қабаты
class RentalRequestService {
  static final RentalRequestService _instance = RentalRequestService._internal();
  factory RentalRequestService() => _instance;
  RentalRequestService._internal();

  final RentalRequestRepository _repo = RentalRequestRepository();

  Future<void> submitRequest(RentalRequestModel request) =>
      _repo.insertRequest(request);

  Future<List<RentalRequestModel>> getAllRequests() => _repo.getAllRequests();

  Future<void> updateStatus(String id, String status) =>
      _repo.updateRequestStatus(id, status);

  Future<void> deleteRequest(String id) => _repo.deleteRequest(id);
}

