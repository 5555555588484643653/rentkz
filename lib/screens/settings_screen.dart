import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkThemeEnabled = false;
  String _selectedLanguage = 'Қазақша';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Тілді таңдаңыз'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedLanguage = 'Қазақша');
              Navigator.pop(ctx);
            },
            child: const Text('Қазақша'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedLanguage = 'Русский');
              Navigator.pop(ctx);
            },
            child: const Text('Русский'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedLanguage = 'English');
              Navigator.pop(ctx);
            },
            child: const Text('English'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Жүйеден шығу'),
        content: const Text('Шынымен аккаунттан шыққыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              AuthService().logout();
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Иә, шығу'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Баптаулар'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('Қолданба параметрлері'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Қараңғы тақырып (Dark Mode)'),
                  subtitle: const Text('Түнгі режимді қосу'),
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                  value: _darkThemeEnabled,
                  onChanged: (val) {
                    setState(() {
                      _darkThemeEnabled = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? 'Қараңғы тақырып таңдалды'
                            : 'Жарық тақырып таңдалды'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Хабарландырулар'),
                  subtitle: const Text('Жаңа пәтерлер мен өтінімдер'),
                  secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.language_outlined, color: AppColors.primary),
                  title: const Text('Қолданба тілі'),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showLanguageDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Қауіпсіздік және деректер'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
                  title: const Text('Құпиясөзді өзгерту'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Құпиясөзді өзгерту сілтемесі поштаңызға жіберілді')),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.primary),
                  title: const Text('Кэшті тазарту'),
                  subtitle: const Text('14.2 MB босатылады'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Кэш сәтті тазартылды')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Қосымша туралы'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('RentKZ нұсқасы'),
                  trailing: Text(
                    'v1.0.0 (Build 1)',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: const Text('Пайдалану шарты'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Шығу батырмасы
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text(
              'Жүйеден шығу',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
