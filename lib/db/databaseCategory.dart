import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  //instancia unica
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  // Constructor factory para crear una única instancia de DatabaseHelper
  factory DatabaseHelper() => _instance;
  static Database? _db;

  Future<String> getDatabaseName() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'gestorypassword.db');
    return path;
  }

  // Método asincrónico para obtener la base de datos SQLite
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }
  // Constructor privado para garantizar que solo se pueda crear una instancia
  DatabaseHelper.internal();
  // Método para inicializar la base de datos
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'categories.db');
    final databaseName = await getDatabaseName();
    print('Nombre de la base de datos: $databaseName');
    // Abre la base de datos o crea una nueva si no existe
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }
  // Método para crear la tabla 'categories' en la base de datos
  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        color INTEGER
      )
    ''');
  }
  // Método para insertar una categoría en la base de datos
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
    // Inserta la categoría en la tabla 'categories'
    return await dbClient.insert('categories', category.toMap());
  }

  // Método para obtener todas las categorías de la base de datos
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
// Clase que representa una categoría
class Category {
  int? id;
  String name;
  int color;

  Category({
    this.id,
    required this.name,
    required this.color,
  });
  // Método para convertir un objeto Category en un mapa (para la inserción en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
  // Constructor factory para crear un objeto Category desde un mapa (resultados de la consulta)
  factory Category.fromMap(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    color: json['color'],
  );
}

