import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../repositories/apartment_repository.dart';
import '../services/apartment_service.dart';
import '../widgets/apartment_card.dart';
import '../theme/app_colors.dart';
import 'apartment_details_screen.dart';
import 'search_screen.dart';

class ApartmentListScreen extends StatefulWidget {
  const ApartmentListScreen({super.key});

  @override
  State<ApartmentListScreen> createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends State<ApartmentListScreen> {
  final ApartmentService _service = ApartmentService();

  SortOrder _sortOrder = SortOrder.newest;
  List<Apartment> _apartments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.search(sortOrder: _sortOrder);
      if (mounted) {
        setState(() {
          _apartments = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Барлық пәтерлер'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
              await _loadApartments();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Сұрыптау
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.sort, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Сұрыптау:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SortOrder>(
                      value: _sortOrder,
                      isDense: true,
                      borderRadius: BorderRadius.circular(12),
                      items: const [
                        DropdownMenuItem(value: SortOrder.newest, child: Text('Жаңасы бірінші')),
                        DropdownMenuItem(value: SortOrder.oldest, child: Text('Ескісі бірінші')),
                        DropdownMenuItem(value: SortOrder.priceAsc, child: Text('Баға: арзаннан')),
                        DropdownMenuItem(value: SortOrder.priceDesc, child: Text('Баға: қымбаттан')),
                        DropdownMenuItem(value: SortOrder.areaAsc, child: Text('Аудан: кішіден')),
                        DropdownMenuItem(value: SortOrder.areaDesc, child: Text('Аудан: үлкеннен')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _sortOrder = val);
                          _loadApartments();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Санақ
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Барлығы: ${_apartments.length} пәтер',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Тізім
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text('Деректерді жүктеу кезінде қате',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadApartments,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Қайталау'),
                            ),
                          ],
                        ),
                      )
                    : _apartments.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.apartment_outlined, size: 64, color: AppColors.primary),
                                SizedBox(height: 16),
                                Text('Пәтерлер жоқ',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _apartments.length,
                            itemBuilder: (context, index) {
                              final apt = _apartments[index];
                              return ApartmentCard(
                                apartment: apt,
                                isFavorite: apt.isFavorite,
                                onFavoritePressed: () async {
                                  await _service.toggleFavorite(apt.id);
                                  await _loadApartments();
                                },
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ApartmentDetailsScreen(
                                        apartment: apt,
                                        onChanged: _loadApartments,
                                      ),
                                    ),
                                  );
                                  await _loadApartments();
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
