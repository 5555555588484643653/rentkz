import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../services/apartment_service.dart';
import '../widgets/apartment_card.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';
import 'apartment_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback onGoToHome;

  const FavoritesScreen({
    super.key,
    required this.onGoToHome,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApartmentService _service = ApartmentService();
  List<Apartment> _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleToggleFavorite(Apartment apartment) async {
    try {
      await _service.toggleFavorite(apartment.id);
      await _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Таңдаулылар'),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              tooltip: 'Жаңарту',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : _favorites.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                '${_favorites.length} пәтер сақталды',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final apartment = _favorites[index];
              return ApartmentCard(
                apartment: apartment,
                isFavorite: true,
                onFavoritePressed: () => _handleToggleFavorite(apartment),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApartmentDetailsScreen(
                        apartment: apartment,
                        onChanged: _loadFavorites,
                      ),
                    ),
                  );
                  await _loadFavorites();
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.primaryLight,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 15, color: AppColors.primary),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Жүрекшені басып, тізімнен алып тастаңыз',
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Таңдаулы пәтерлер жоқ',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: -0.3, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ұнаған пәтердің жүрекше белгісін басыңыз. Ол осы жерде сақталады.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Пәтерлерді қарау',
              onPressed: widget.onGoToHome,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Деректерді жүктеу кезінде қате',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Қайталау'),
            ),
          ],
        ),
      ),
    );
  }
}
