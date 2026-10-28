import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final success = AuthService().register(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (success) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Тіркелу кезінде қате орын алды'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Тіркелу'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Жаңа аккаунт ашу',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'RentKZ жүйесінде өз аккаунтыңызды жасаңыз',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Аты-жөні
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Аты-жөніңіз *',
                  hintText: 'Әлихан Серікұлы',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Аты-жөніңізді енгізіңіз';
                    }
                    if (value.trim().length < 2) {
                      return 'Аты-жөні кемінде 2 әріптен тұруы керек';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Телефон
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Телефон нөмірі *',
                  hintText: '+7 700 123 45 67',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Телефон нөмірін енгізіңіз';
                    }
                    if (value.trim().length < 10) {
                      return 'Дұрыс телефон нөмірін жазыңыз';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Электронды пошта *',
                  hintText: 'example@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Электронды пошта бос болмауы керек';
                    }
                    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegExp.hasMatch(value.trim())) {
                      return 'Дұрыс email форматын енгізіңіз';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Құпиясөз
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Құпиясөз *',
                  hintText: 'Кемінде 6 таңба',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Құпиясөзді енгізіңіз';
                    }
                    if (value.length < 6) {
                      return 'Құпиясөз кемінде 6 таңба болуы керек';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Құпиясөзді қайталау
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Құпиясөзді қайталаңыз *',
                  hintText: 'Құпиясөзді қайта енгізіңіз',
                  prefixIcon: Icons.lock_clock_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Құпиясөзді қайталау міндетті';
                    }
                    if (value != _passwordController.text) {
                      return 'Құпиясөздер бір-біріне сәйкес келмейді';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Тіркелу',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Аккаунтыңыз бар ма? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Кіру',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
