import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite деректер қорымен жұмыс істейтін негізгі helper класс.
/// Singleton pattern пайдаланылған.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  /// Деректер қорын ашу немесе жасау
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rentkz.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Кестелерді бастапқы жасау
  Future<void> _onCreate(Database db, int version) async {
    // 1. Пәтерлер кестесі
    await db.execute('''
      CREATE TABLE apartments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        address TEXT NOT NULL,
        price TEXT NOT NULL,
        priceNum REAL NOT NULL,
        roomsCount INTEGER NOT NULL,
        rooms TEXT NOT NULL,
        area TEXT NOT NULL,
        floor TEXT NOT NULL,
        description TEXT NOT NULL,
        amenities TEXT NOT NULL,
        imageUrl TEXT,
        ownerName TEXT NOT NULL,
        ownerPhone TEXT NOT NULL,
        isLongTerm INTEGER NOT NULL DEFAULT 1,
        isAvailable INTEGER NOT NULL DEFAULT 1,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // 2. Жалға алу өтінімдері кестесі
    await db.execute('''
      CREATE TABLE rental_requests (
        id TEXT PRIMARY KEY,
        apartmentId TEXT NOT NULL,
        apartmentTitle TEXT NOT NULL,
        apartmentPrice TEXT NOT NULL,
        fullName TEXT NOT NULL,
        phone TEXT NOT NULL,
        moveDate TEXT NOT NULL,
        message TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        createdAt TEXT NOT NULL
      )
    ''');

    // 3. Іздеу тарихы кестесі
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        searchedAt TEXT NOT NULL
      )
    ''');

    // 4. Қолданушы баптаулары кестесі
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Бастапқы деректерді енгізу
    await _insertInitialData(db);
  }

  /// Бастапқы mock деректерді SQLite-қа жазу
  Future<void> _insertInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final apartments = [
      {
        'id': '1',
        'title': 'Есілдегі жайлы пәтер',
        'address': 'Астана, Есіл ауданы, Түркістан к-сі, 14',
        'price': '250 000 ₸ / ай',
        'priceNum': 250000.0,
        'roomsCount': 2,
        'rooms': '2 бөлме',
        'area': '58 м²',
        'floor': '7 / 12 қабат',
        'description':
            'Жарық әрі жылы пәтер. Жиһаз бен тұрмыстық техника толық бар. Ботаникалық баққа жақын, аялдама мен дүкендер жаяу қашықтықта.',
        'amenities': 'Интернет,Жиһаз,Кір жуғыш,Кондиционер,Тоңазытқыш',
        'imageUrl': '',
        'ownerName': 'Айгүл',
        'ownerPhone': '+7 (701) 234 56 78',
        'isLongTerm': 1,
        'isAvailable': 1,
        'isFavorite': 1,
        'createdAt': now,
      },
      {
        'id': '2',
        'title': 'Сарыарқадағы жарық пәтер',
        'address': 'Астана, Сарыарқа ауданы, Кенесары к-сі, 40',
        'price': '180 000 ₸ / ай',
        'priceNum': 180000.0,
        'roomsCount': 1,
        'rooms': '1 бөлме',
        'area': '38 м²',
        'floor': '4 / 9 қабат',
        'description':
            'Ыңғайлы орналасқан, жақында евроремонт жасалған таза пәтер. Барлық қажетті жағдайлар қарастырылған.',
        'amenities': 'Интернет,Жиһаз,Тұрмыстық техника',
        'imageUrl': '',
        'ownerName': 'Нұржан',
        'ownerPhone': '+7 (702) 555 33 22',
        'isLongTerm': 1,
        'isAvailable': 1,
        'isFavorite': 1,
        'createdAt': now,
      },
      {
        'id': '3',
        'title': 'Заманауи 1 бөлмелі пәтер',
        'address': 'Астана, Алматы ауданы, Тәуелсіздік даңғылы, 32',
        'price': '120 000 ₸ / ай',
        'priceNum': 120000.0,
        'roomsCount': 1,
        'rooms': '1 бөлме',
        'area': '35 м²',
        'floor': '3 / 10 қабат',
        'description':
            'Жас отбасыларға немесе студенттерге арналған жайлы пәтер. Тыныш аула, шлагбаум.',
        'amenities': 'Интернет,Жиһаз',
        'imageUrl': '',
        'ownerName': 'Ерлан',
        'ownerPhone': '+7 (777) 111 22 33',
        'isLongTerm': 1,
        'isAvailable': 1,
        'isFavorite': 0,
        'createdAt': now,
      },
      {
        'id': '4',
        'title': 'Кең 3 бөлмелі пәтер',
        'address': 'Астана, Есіл ауданы, Қабанбай батыр даңғылы, 15',
        'price': '320 000 ₸ / ай',
        'priceNum': 320000.0,
        'roomsCount': 3,
        'rooms': '3 бөлме',
        'area': '92 м²',
        'floor': '9 / 16 қабат',
        'description':
            'Премиум кластағы үй. Екі санузел, гардероб бөлмесі, панорамалық терезелер.',
        'amenities':
            'Интернет,Жиһаз,Кір жуғыш,Кондиционер,Ыдыс жуғыш машина',
        'imageUrl': '',
        'ownerName': 'Динара',
        'ownerPhone': '+7 (705) 444 88 99',
        'isLongTerm': 1,
        'isAvailable': 1,
        'isFavorite': 0,
        'createdAt': now,
      },
    ];

    for (final apt in apartments) {
      await db.insert('apartments', apt);
    }
  }

  /// Деректер қорын жабу
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}

