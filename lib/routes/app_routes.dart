import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_container_screen.dart';
import '../screens/search_screen.dart';
import '../screens/apartment_list_screen.dart';
import '../screens/apartment_details_screen.dart';
import '../screens/rental_request_screen.dart';
import '../screens/create_edit_apartment_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String search = '/search';
  static const String apartmentList = '/apartment_list';
  static const String details = '/details';
  static const String rentalRequest = '/rental_request';
  static const String createEditApartment = '/create_edit_apartment';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainContainerScreen());
      case search:
        final query = routeSettings.arguments as String?;
        return MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: query));
      case apartmentList:
        return MaterialPageRoute(builder: (_) => const ApartmentListScreen());
      case details:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ApartmentDetailsScreen(
            apartment: args['apartment'] as Apartment,
            isFavorite: args['isFavorite'] as bool? ?? false,
            onFavoritePressed: args['onFavoritePressed'] as VoidCallback? ?? () {},
          ),
        );
      case rentalRequest:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RentalRequestScreen(
            apartmentTitle: args['apartmentTitle'] as String,
            apartmentPrice: args['apartmentPrice'] as String,
          ),
        );
      case createEditApartment:
        final apt = routeSettings.arguments as Apartment?;
        return MaterialPageRoute(
          builder: (_) => CreateEditApartmentScreen(apartmentToEdit: apt),
        );
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Бет табылмады: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
