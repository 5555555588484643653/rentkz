import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../services/apartment_service.dart';
import '../repositories/apartment_repository.dart';
import '../widgets/apartment_card.dart';
import '../widgets/section_header.dart';
import '../theme/app_colors.dart';
import 'apartment_details_screen.dart';
import 'apartment_list_screen.dart';
import 'search_screen.dart';
import 'create_edit_apartment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApartmentService _service = ApartmentService();
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  int _selectedFilterIndex = 0;
  SortOrder _sortOrder = SortOrder.newest;

  List<Apartment> _apartments = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _filters = [
    'Барлығы',
    '1 бөлмелі',
    '2 бөлмелі',
    '3+ бөлмелі',
  ];

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
    _loadApartments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.search(
        query: _searchText,
        roomsFilter: _selectedFilterIndex,
        sortOrder: _sortOrder,
      );
      if (mounted) {
        setState(() {
          _apartments = result;
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
      await _loadApartments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete(Apartment apartment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Жою'),
        content: Text('"${apartment.title}" жою керек пе?'),
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
        await _service.deleteApartment(apartment.id);
        await _loadApartments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пәтер жойылды')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Қате: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'RentKZ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          // Сұрыптау
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort, color: AppColors.primary),
            tooltip: 'Сұрыптау',
            onSelected: (order) {
              setState(() => _sortOrder = order);
              _loadApartments();
            },
            itemBuilder: (_) => _sortOptions.map((opt) {
              return PopupMenuItem(
                value: opt.value,
                child: Row(
                  children: [
                    if (_sortOrder == opt.value)
                      const Icon(Icons.check, color: AppColors.primary, size: 18),
                    if (_sortOrder != opt.value) const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(opt.label),
                  ],
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Астана',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateEditApartmentScreen()),
          );
          if (added == true && mounted) {
            await _loadApartments();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Хабарландыру қосу',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text(
            'Өзіңе лайықты үй тап',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.25),
          ),
          const SizedBox(height: 6),
          const Text(
            'Жаңа өміріңіз жайлы үйден басталады.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Іздеу өрісі
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchText = value);
              _loadApartments();
            },
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Аудан немесе мекенжай іздеу',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchText.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchText = '');
                        _loadApartments();
                      },
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchScreen(initialQuery: _searchText),
                        ),
                      );
                      await _loadApartments();
                    },
                    icon: const Icon(Icons.tune, color: AppColors.primary, size: 20),
                    tooltip: 'Кеңейтілген сүзгілер',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Сүзгі чиптері
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _filters[index],
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedFilterIndex = index);
                      _loadApartments();
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          SectionHeader(
            title: 'Жалға берілетін пәтерлер',
            actionTitle: 'Барлығын көру',
            onActionTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApartmentListScreen()),
              );
              await _loadApartments();
            },
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_apartments.length} пәтер',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Деректер күйі
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            _buildErrorWidget()
          else if (_apartments.isEmpty)
            _buildEmptyWidget()
          else
            ..._apartments.map(
              (apartment) => ApartmentCard(
                apartment: apartment,
                isFavorite: apartment.isFavorite,
                onFavoritePressed: () => _handleToggleFavorite(apartment),
                onLongPress: () => _handleDelete(apartment),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApartmentDetailsScreen(
                        apartment: apartment,
                        onChanged: _loadApartments,
                      ),
                    ),
                  );
                  await _loadApartments();
                },
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Пәтер табылмады',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Басқа кілт сөзбен немесе сүзгімен\nіздеп көріңіз.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Деректерді жүктеу кезінде қате орын алды',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadApartments,
            icon: const Icon(Icons.refresh),
            label: const Text('Қайталау'),
          ),
        ],
      ),
    );
  }
}
