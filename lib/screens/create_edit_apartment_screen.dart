import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../services/apartment_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_colors.dart';

class CreateEditApartmentScreen extends StatefulWidget {
  final Apartment? apartmentToEdit;

  const CreateEditApartmentScreen({super.key, this.apartmentToEdit});

  @override
  State<CreateEditApartmentScreen> createState() =>
      _CreateEditApartmentScreenState();
}

class _CreateEditApartmentScreenState
    extends State<CreateEditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApartmentService _service = ApartmentService();

  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _floorController;
  late TextEditingController _areaController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _ownerNameController;

  int _roomsCount = 2;
  bool _isLongTerm = true;
  bool _isSaving = false;
  final List<String> _selectedAmenities = [];

  final List<String> _availableAmenities = [
    'Интернет',
    'Жиһаз',
    'Кір жуғыш',
    'Кондиционер',
    'Тоңазытқыш',
    'Ыдыс жуғыш машина',
    'Тұрмыстық техника',
    'Теледидар',
    'Балкон',
  ];

  bool get isEditing => widget.apartmentToEdit != null;

  @override
  void initState() {
    super.initState();
    final apt = widget.apartmentToEdit;
    _titleController = TextEditingController(text: apt?.title ?? '');
    _addressController =
        TextEditingController(text: apt?.address ?? 'Астана, ');
    _priceController = TextEditingController(
      text: apt != null ? apt.priceNum.toInt().toString() : '',
    );
    _floorController =
        TextEditingController(text: apt?.floor ?? '5 / 9 қабат');
    _areaController = TextEditingController(
      text: apt != null
          ? apt.area.replaceAll(RegExp(r'[^0-9]'), '')
          : '50',
    );
    _descriptionController =
        TextEditingController(text: apt?.description ?? '');
    _phoneController = TextEditingController(
        text: apt?.ownerPhone ?? '+7 (701) 234 56 78');
    _ownerNameController =
        TextEditingController(text: apt?.ownerName ?? 'Пәтер иесі');

    if (apt != null) {
      _roomsCount = apt.roomsCount;
      _isLongTerm = apt.isLongTerm;
      _selectedAmenities.addAll(apt.amenities);
    } else {
      _selectedAmenities.addAll(['Интернет', 'Жиһаз', 'Тоңазытқыш']);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _floorController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  Future<void> _saveApartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final priceRaw =
          int.tryParse(_priceController.text.trim().replaceAll(' ', '')) ?? 0;
      final priceFormatted =
          '${_priceController.text.trim().replaceAll(RegExp(r'\s+'), ' ')} ₸ / ай';
      final areaFormatted = '${_areaController.text.trim()} м²';

      final apartment = Apartment(
        id: widget.apartmentToEdit?.id ??
            'apt_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        price: priceFormatted,
        priceNum: priceRaw.toDouble(),
        roomsCount: _roomsCount,
        rooms: '$_roomsCount бөлме',
        area: areaFormatted,
        floor: _floorController.text.trim(),
        description: _descriptionController.text.trim(),
        amenities: List.from(_selectedAmenities),
        imageUrl: widget.apartmentToEdit?.imageUrl ?? '',
        ownerName: _ownerNameController.text.trim(),
        ownerPhone: _phoneController.text.trim(),
        isLongTerm: _isLongTerm,
        isAvailable: true,
        isFavorite: widget.apartmentToEdit?.isFavorite ?? false,
        createdAt: widget.apartmentToEdit?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await _service.updateApartment(apartment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пәтер туралы мәлімет сәтті жаңартылды')),
          );
        }
      } else {
        await _service.addApartment(apartment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Жаңа хабарландыру сәтті қосылды')),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Сақтау кезінде қате: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? 'Пәтерді өңдеу' : 'Жаңа хабарландыру қосу'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Хабарландыру атауы *',
                hintText: 'Мысалы: Есілдегі жайлы 2 бөлмелі пәтер',
                prefixIcon: Icons.title,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Хабарландыру атауын жазу міндетті';
                  }
                  if (val.trim().length < 5) {
                    return 'Атау кемінде 5 таңбадан тұруы керек';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _addressController,
                labelText: 'Мекенжайы *',
                hintText: 'Қала, аудан, көше және үй нөмірі',
                prefixIcon: Icons.location_on_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Мекенжайды көрсету міндетті';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _ownerNameController,
                labelText: 'Иесінің аты-жөні *',
                hintText: 'Мысалы: Айгүл',
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Иесінің атын жазыңыз';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: 'Бағасы (теңге/ай) *',
                      hintText: '250000',
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Бағасын енгізіңіз';
                        }
                        if (int.tryParse(val.replaceAll(' ', '')) == null) {
                          return 'Тек сан енгізіңіз';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _areaController,
                      labelText: 'Ауданы (м²) *',
                      hintText: '58',
                      prefixIcon: Icons.square_foot,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ауданын жазыңыз';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Бөлме саны
              const Text(
                'Бөлме саны *',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3, 4].map((rooms) {
                  final isSelected = _roomsCount == rooms;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            rooms == 4 ? '4+' : '$rooms бөлме',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFFF1F5F9),
                        onSelected: (selected) {
                          if (selected) setState(() => _roomsCount = rooms);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _floorController,
                labelText: 'Қабаты *',
                hintText: 'Мысалы: 7 / 12 қабат',
                prefixIcon: Icons.stairs_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Қабатын көрсету міндетті';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                labelText: 'Байланыс телефоны *',
                hintText: '+7 701 234 56 78',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Телефон нөмірін енгізіңіз';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Толық сипаттамасы *',
                hintText:
                    'Пәтердің жағдайы, инфрақұрылымы туралы толығырақ жазыңыз...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Сипаттама жазу міндетті';
                  }
                  if (val.trim().length < 10) {
                    return 'Сипаттама кемінде 10 таңба болуы керек';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Жалға беру мерзімі
              Row(
                children: [
                  const Text(
                    'Жалға беру мерзімі:',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Ұзақ мерзім'),
                    selected: _isLongTerm,
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: _isLongTerm
                            ? AppColors.primary
                            : AppColors.textPrimary),
                    onSelected: (_) => setState(() => _isLongTerm = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Тәуліктік'),
                    selected: !_isLongTerm,
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: !_isLongTerm
                            ? AppColors.primary
                            : AppColors.textPrimary),
                    onSelected: (_) => setState(() => _isLongTerm = false),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Қолайлылықтар
              const Text(
                'Қолайлылықтар мен техника',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableAmenities.map((amenity) {
                  final isChecked = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isChecked,
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isChecked
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isChecked
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: isEditing
                    ? 'Өзгерістерді сақтау'
                    : 'Хабарландыруды жариялау',
                icon: isEditing
                    ? Icons.save_outlined
                    : Icons.add_circle_outline,
                onPressed: _isSaving ? null : _saveApartment,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
