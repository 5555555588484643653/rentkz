import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../repositories/apartment_repository.dart';
import '../services/apartment_service.dart';
import '../widgets/apartment_card.dart';
import '../theme/app_colors.dart';
import 'apartment_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApartmentService _service = ApartmentService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedRooms = 0;
  double _maxPrice = 500000;
  SortOrder _sortOrder = SortOrder.newest;

  List<Apartment> _results = [];
  bool _isLoading = false;

  final List<String> _roomFilters = ['Барлығы', '1 бөлмелі', '2 бөлмелі', '3+ бөлмелі'];

  final List<({String label, SortOrder value})> _sortOptions = [
    (label: 'Жаңалары', value: SortOrder.newest),
    (label: 'Баға ↑', value: SortOrder.priceAsc),
    (label: 'Баға ↓', value: SortOrder.priceDesc),
    (label: 'Ауданы ↑', value: SortOrder.areaAsc),
    (label: 'Ауданы ↓', value: SortOrder.areaDesc),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.search(
        query: _searchQuery,
        roomsFilter: _selectedRooms,
        maxPrice: _maxPrice,
        sortOrder: _sortOrder,
      );
      if (mounted) {
        setState(() {
          _results = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Іздеу қатесі: $e')),
        );
      }
    }
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedRooms = 0;
      _maxPrice = 500000;
      _sortOrder = SortOrder.newest;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пәтер іздеу'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Іздеу жолағы
                TextField(
                  controller: _searchController,
                  autofocus: widget.initialQuery == null,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _performSearch();
                  },
                  decoration: InputDecoration(
                    hintText: 'Аудан, көше немесе ЖК атауы',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _performSearch();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Бөлме сүзгілері
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _roomFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedRooms == index;
                      return ChoiceChip(
                        label: Text(
                          _roomFilters[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFFF1F5F9),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onSelected: (selected) {
                          setState(() => _selectedRooms = index);
                          _performSearch();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Баға диапазоны
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Максималды баға:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${_maxPrice.toInt()} ₸ / ай',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _maxPrice,
                  min: 100000,
                  max: 1000000,
                  divisions: 18,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _maxPrice = val),
                  onChangeEnd: (_) => _performSearch(),
                ),

                // Сұрыптау
                Row(
                  children: [
                    const Text('Сұрыптау:',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _sortOptions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (ctx, i) {
                            final opt = _sortOptions[i];
                            final isSelected = _sortOrder == opt.value;
                            return ChoiceChip(
                              label: Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onSelected: (_) {
                                setState(() => _sortOrder = opt.value);
                                _performSearch();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Нәтижелер тақырыбы
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isLoading
                      ? 'Іздеу жүріп жатыр...'
                      : 'Табылған пәтерлер (${_results.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_searchQuery.isNotEmpty ||
                    _selectedRooms != 0 ||
                    _maxPrice < 500000)
                  GestureDetector(
                    onTap: _resetFilters,
                    child: const Text(
                      'Тазарту',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Нәтижелер
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search_off_rounded,
                                    size: 48, color: AppColors.primary),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Сәйкес пәтер табылмады',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Сүзгі шарттарын өзгертіп немесе баға лимитін көтеріп көріңіз',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final apt = _results[index];
                          return ApartmentCard(
                            apartment: apt,
                            isFavorite: apt.isFavorite,
                            onFavoritePressed: () async {
                              await _service.toggleFavorite(apt.id);
                              await _performSearch();
                            },
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApartmentDetailsScreen(
                                    apartment: apt,
                                    onChanged: _performSearch,
                                  ),
                                ),
                              );
                              await _performSearch();
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
