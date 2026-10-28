import 'package:flutter/material.dart';
import '../models/rental_request.dart';
import '../services/rental_request_service.dart';
import '../theme/app_colors.dart';

class RentalRequestScreen extends StatefulWidget {
  final String apartmentId;
  final String apartmentTitle;
  final String apartmentPrice;

  const RentalRequestScreen({
    super.key,
    required this.apartmentId,
    required this.apartmentTitle,
    required this.apartmentPrice,
  });

  @override
  State<RentalRequestScreen> createState() => _RentalRequestScreenState();
}

class _RentalRequestScreenState extends State<RentalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Әлихан Серікұлы');
  final _phoneController = TextEditingController(text: '+7 (701) 234 56 78');
  final _messageController = TextEditingController(
    text: 'Сәлеметсіз бе! Пәтеріңізді ұзақ мерзімге жалға алғым келеді. Қашан көруге болады?',
  );

  DateTime? _moveDate = DateTime(2026, 11, 1);
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _moveDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Көшу күнін таңдаңыз',
      cancelText: 'Болдырмау',
      confirmText: 'Таңдау',
    );
    if (selectedDate != null && mounted) {
      setState(() => _moveDate = selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_moveDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Көшу күнін таңдаңыз')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final request = RentalRequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        apartmentId: widget.apartmentId,
        apartmentTitle: widget.apartmentTitle,
        apartmentPrice: widget.apartmentPrice,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        moveDate: _formatDate(_moveDate!),
        message: _messageController.text.trim(),
      );

      await RentalRequestService().submitRequest(request);

      if (!mounted) return;

      // Сәтті диалог
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EEFC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Өтінім қабылданды!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Өтініміңіз пәтер иесіне жіберілді. Иесі сізге жақын арада хабарласады.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.apartmentTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.apartmentPrice,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Көшу күні: ${_formatDate(_moveDate!)}',
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Жарайды', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Өтінім жіберу кезінде қате: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = AppColors.primary;
    final dateStr = _moveDate == null ? 'Күнді таңдаңыз' : _formatDate(_moveDate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Жалға алуға өтінім',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            // Пәтер картасы
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6EAF0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apartment_rounded, color: mainColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.apartmentTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.apartmentPrice,
                          style: const TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Байланыс деректеріңіз',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: -0.2),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Аты-жөніңіз',
                labelStyle: TextStyle(fontSize: 14),
                prefixIcon: Icon(Icons.person_outline, color: mainColor, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Аты-жөніңізді енгізіңіз';
                if (value.trim().length < 3) return 'Аты-жөніңіз тым қысқа';
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Телефон нөмірі',
                labelStyle: TextStyle(fontSize: 14),
                prefixIcon: Icon(Icons.phone_outlined, color: mainColor, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 6) return 'Дұрыс телефон нөмірін енгізіңіз';
                return null;
              },
            ),

            const SizedBox(height: 14),

            InkWell(
              onTap: _chooseDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Жалдау басталатын күн',
                  labelStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.calendar_month, color: mainColor, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 15,
                        color: _moveDate != null ? Colors.black87 : Colors.black45,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _messageController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                labelText: 'Пәтер иесіне хабарлама',
                labelStyle: TextStyle(fontSize: 14),
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Өтінім жіберу арқылы байланыс деректеріңізді пәтер иесіне беруге келісесіз.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            FilledButton(
              onPressed: _isSending ? null : _submitRequest,
              style: FilledButton.styleFrom(
                backgroundColor: mainColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Өтінім жіберу',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Өтінім беру тегін. Жауапты "Өтінімдер" бөлімінен аласыз.',
                style: TextStyle(color: Colors.black45, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
