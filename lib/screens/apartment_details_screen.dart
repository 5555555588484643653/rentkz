import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../services/apartment_service.dart';
import '../widgets/amenity_chip.dart';
import '../theme/app_colors.dart';
import 'rental_request_screen.dart';
import 'create_edit_apartment_screen.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final Apartment apartment;
  final VoidCallback? onChanged;

  const ApartmentDetailsScreen({
    super.key,
    required this.apartment,
    this.onChanged,
  });

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  final ApartmentService _service = ApartmentService();
  late bool _isFavorite;
  late Apartment _apartment;

  @override
  void initState() {
    super.initState();
    _apartment = widget.apartment;
    _isFavorite = widget.apartment.isFavorite;
  }

  Future<void> _handleToggleFavorite() async {
    try {
      final newState = await _service.toggleFavorite(_apartment.id);
      setState(() {
        _isFavorite = newState;
        _apartment = _apartment.copyWith(isFavorite: newState);
      });
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Жою'),
        content: Text('"${_apartment.title}" жою керек пе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Бас тарту'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Жою'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.deleteApartment(_apartment.id);
        widget.onChanged?.call();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Қате: $e')),
          );
        }
      }
    }
  }

  IconData _getAmenityIcon(String amenity) {
    if (amenity.contains('Интернет')) return Icons.wifi;
    if (amenity.contains('Жиһаз')) return Icons.chair;
    if (amenity.contains('Кір жуғыш')) return Icons.local_laundry_service;
    if (amenity.contains('Кондиционер')) return Icons.ac_unit;
    if (amenity.contains('Тоңазытқыш')) return Icons.kitchen;
    if (amenity.contains('Ыдыс жуғыш')) return Icons.wash;
    if (amenity.contains('Тұрмыстық техника')) return Icons.electrical_services;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Пәтер туралы',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateEditApartmentScreen(
                    apartmentToEdit: _apartment,
                  ),
                ),
              );
              if (updated == true) {
                // Жаңартылған пәтерді қайта оқу
                final fresh = await _service.getById(_apartment.id);
                if (fresh != null && mounted) {
                  setState(() {
                    _apartment = fresh;
                    _isFavorite = fresh.isFavorite;
                  });
                }
                widget.onChanged?.call();
              }
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Хабарландыруды өңдеу',
          ),
          IconButton(
            onPressed: _handleDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Жою',
          ),
          IconButton(
            onPressed: _handleToggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppColors.textPrimary,
            ),
            tooltip: _isFavorite ? 'Таңдаулыдан алып тастау' : 'Таңдаулыға қосу',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // Фото аймағы
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.apartment_rounded, size: 90, color: AppColors.primary),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '1 / 6',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _apartment.isLongTerm ? 'Ұзақ мерзімге' : 'Тәуліктік',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Бос',
                  style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            _apartment.price,
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _apartment.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.25),
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _apartment.address,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                _buildStatItem(Icons.bed_outlined, _apartment.rooms, 'Бөлме саны'),
                _buildDivider(),
                _buildStatItem(Icons.square_foot, _apartment.area, 'Жалпы ауданы'),
                _buildDivider(),
                _buildStatItem(Icons.layers_outlined, _apartment.floor, 'Қабаты'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Сипаттама',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              _apartment.description,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
            ),
          ),

          const SizedBox(height: 20),

          const Text('Қолайлылықтар',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2)),
          const SizedBox(height: 10),
          _apartment.amenities.isEmpty
              ? const Text('Қолайлылықтар көрсетілмеген',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _apartment.amenities
                      .map((amenity) => AmenityChip(
                            label: amenity,
                            icon: _getAmenityIcon(amenity),
                          ))
                      .toList(),
                ),

          const SizedBox(height: 20),

          const Text('Пәтер иесі туралы',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _apartment.ownerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _apartment.ownerPhone,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Қоңырау шалу: ${_apartment.ownerPhone}')),
                    );
                  },
                  icon: const Icon(Icons.phone, color: AppColors.primary, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RentalRequestScreen(
                  apartmentId: _apartment.id,
                  apartmentTitle: _apartment.title,
                  apartmentPrice: _apartment.price,
                ),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.calendar_month, size: 20),
          label: const Text(
            'Жалға алуға өтінім беру',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: AppColors.cardBorder);
  }
}
