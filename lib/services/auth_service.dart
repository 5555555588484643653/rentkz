class UserModel {
  final String id;
  String name;
  String email;
  String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser = UserModel(
    id: 'user_1',
    name: 'Әлихан Серікұлы',
    email: 'alikhan@rentkz.kz',
    phone: '+7 (701) 234 56 78',
  );

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool login(String email, String password) {
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        id: 'user_1',
        name: 'Әлихан Серікұлы',
        email: email,
        phone: '+7 (701) 234 56 78',
      );
      return true;
    }
    return false;
  }

  bool register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
      );
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }

  void updateProfile({String? name, String? phone, String? email}) {
    if (_currentUser != null) {
      if (name != null && name.isNotEmpty) _currentUser!.name = name;
      if (phone != null && phone.isNotEmpty) _currentUser!.phone = phone;
      if (email != null && email.isNotEmpty) _currentUser!.email = email;
    }
  }
}
