import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  // Flutter binding инициализациялау (sqflite үшін міндетті)
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite деректер қорын іске қосу
  await DatabaseHelper().database;

  runApp(const RentKZApp());
}

class RentKZApp extends StatelessWidget {
  const RentKZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RentKZ',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
