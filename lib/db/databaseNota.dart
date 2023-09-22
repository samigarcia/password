import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Define una clase `Notea` para representar las notas
class Notea {
  final int? id; // ID de la nota (puede ser nulo para notas nuevas)
  final String title; // Título de la nota
  final String content; // Contenido de la nota

  // Constructor de la clase `Notea`
  Notea({
    this.id,
    required this.title,
    required this.content,
  });

  // Convierte una instancia de `Notea` a un mapa (para su almacenamiento en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  // Constructor de fábrica para crear una instancia de `Notea` a partir de un mapa
  factory Notea.fromMap(Map<String, dynamic> map) {
    return Notea(
      id: map['id'],
      title: map['title'],
      content: map['content'],
    );
  }
}

// Define una clase `DatabaseNota` para interactuar con la base de datos de notas
class DatabaseNota {
  static final DatabaseNota instance =
      DatabaseNota._init(); // Instancia única de la base de datos

  static Database? _database; // Base de datos SQLite

  DatabaseNota._init(); // Constructor privado para la inicialización

  // Getter para obtener la base de datos (crea la base de datos si no existe)
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  // Inicializa la base de datos SQLite
  Future<Database> _initDB(String filePath) async {
    final dbPath =
        await getDatabasesPath(); // Obtiene el directorio de la base de datos
    final path = join(dbPath,
        filePath); // Une el directorio y el nombre del archivo de la base de datos

    return await openDatabase(
      path,
      version: 1, // Versión de la base de datos
      onCreate:
          _createDB, // Función para crear la estructura de la base de datos
    );
  }

  // Crea la estructura de la base de datos
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }

  // Inserta una nueva nota en la base de datos
  Future<int> insert(Notea note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Obtiene todas las notas de la base de datos y las convierte en una lista de `Notea`
  Future<List<Notea>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');
    return result.map((e) => Notea.fromMap(e)).toList();
  }

  // Actualiza una nota en la base de datos
  Future<int> update(Notea note) async {
    final db = await instance.database;
    final id = note.id;
    return await db
        .update('notes', note.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  // Elimina una nota de la base de datos
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
