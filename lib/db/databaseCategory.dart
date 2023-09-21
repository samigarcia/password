import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'categories.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        color INTEGER
      )
    ''');
  }

  Future<int> insertCategory(Category category) async {
    final dbClient = await db;

    // Verificar si ya existe una categoría con el mismo color
    final existingCategories = await dbClient!.query(
      'categories',
      where: 'color = ?',
      whereArgs: [category.color],
    );

    if (existingCategories.isNotEmpty) {
      // Ya existe una categoría con el mismo color, puedes manejar el error aquí
      return -1; // O algún otro valor que indique que la inserción falló
    }

    return await dbClient.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final dbClient = await db;
    final list = await dbClient!.query('categories');
    return list.map((json) => Category.fromMap(json)).toList();
  }

  /*Future<int> deleteCategory(String categoryName) async {
    final dbClient = await db;
    return await dbClient!.delete(
      'categories',
      where: 'name = ?',
      whereArgs: [categoryName],
    );
  }*/
}

class Category {
  int? id;
  String name;
  int color;

  Category({
    this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        color: json['color'],
      );
}
