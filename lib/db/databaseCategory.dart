import 'package:app_2/db/notesdb.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:math';
import 'dart:typed_data';

class DatabaseHelper {
  // Instancia única de la clase para el patrón Singleton.
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  // Fábrica para obtener la instancia única.
  factory DatabaseHelper() => _instance;

  // Variable para almacenar la base de datos.
  static Database? _db;

  // Clave y cifrador para la encriptación de datos.
  late final encrypt.Key key;
  late final encrypt.Encrypter encrypter;

  // Constructor privado para la inicialización.
  DatabaseHelper.internal() {
    // Clave de cifrado generada aleatoriamente al inicio.
    final random = Random.secure();
    key = encrypt.Key(Uint8List.fromList(
        List<int>.generate(32, (index) => random.nextInt(256))));
    encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  // Función para imprimir nombres de tablas en la base de datos.
  Future<void> printTableNames() async {
    final db = await this.db;
    final result =
    await db!.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final tableNames = result.map((row) => row['name'] as String).toList();

    for (final tableName in tableNames) {
      print('Nombre de la tabla: $tableName');
    }
  }

  // Función para obtener la ruta de la base de datos.
  Future<String> getDatabaseName() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'gestorypassword.db');
    return path;
  }

  // Getter para obtener la base de datos.
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  // Función para inicializar la base de datos si no existe.
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'categories.db');
    final databaseName = await getDatabaseName();
    print('Nombre de la base de datos: $databaseName');
    return await openDatabase(path, version: 3, onCreate: _onCreate);
  }

  // Función para crear las tablas en la base de datos.
  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT,
        color INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        category_id INTEGER,
        iv TEXT, 
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
    CREATE TABLE images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image_path TEXT
    )
    ''');
  }

/*  // Función para cargar una imagen desde activos y guardarla en la base de datos
  Future<void> insertImageFromAssets(Uint8List uint8list) async {
    try {
      // Lee la imagen desde el archivo de activos
      final ByteData assetByteData = await rootBundle.load('assets/imagen.jpg');
      final List<int> imageBytes = assetByteData.buffer.asUint8List();

      // Convierte los bytes de la imagen en un objeto Uint8List
      final Uint8List uint8list = Uint8List.fromList(imageBytes);

      // Inserta la imagen en la base de datos
      final db = await this.db;
      await db!.insert('images', {'image_data': uint8list});
      print('Imagen insertada en la base de datos');
    } catch (e) {
      print('Error al cargar la imagen desde activos: $e');
    }
  }*/
  // Función para insertar una ruta de imagen en la base de datos.
  Future<void> insertImageAssets(String imagePath) async {
    final db = await this.db;
    await db?.insert('images', {'image_path': imagePath});
  }

  // Función para insertar una ruta de imagen en la base de datos.
  Future<void> insertImage(String imagePath) async {
    final db = await this.db;
    await db!.delete('images');
    await db.insert('images', {'image_path': imagePath});
  }


  // Función para insertar una categoría en la base de datos.
  Future<int> insertCategory(Category category) async {
    final dbClient = await db;
    final existingCategories = await dbClient!.query(
      'categories',
      where: 'color = ?',
      whereArgs: [category.color],
    );
    if (existingCategories.isNotEmpty) {
      return -1;
    }
    return await dbClient.insert('categories', category.toMap());
  }

  // Función para obtener todas las categorías de la base de datos.
  Future<List<Category>> getCategories() async {
    final dbClient = await db;
    final list = await dbClient!.query('categories');
    return list.map((json) => Category.fromMap(json)).toList();
  }

  // Función para obtener todas las notas de la base de datos.
  Future<List<Notea>> getAllNotes() async {
    final db = await _instance.db;
    final result = await db!.query('notes');
    final notes = result.map((json) {
      final content = json['content'] as String?;
      final iv = json['iv'] as String?;
      //if (content != null && iv != null) {
      if (content == iv) {
        final decryptedText = decryptText(content!, iv!);
        json['content'] = decryptedText;
      }
      return Notea.fromMap(json);
    }).toList();
    return notes;
  }

  // Función para cifrar un texto con un IV y devolver el texto cifrado en Base64.
  String encryptText(String text, encrypt.IV iv) {
    final encryptedText = encrypter.encrypt(text, iv: iv);
    return encryptedText.base64;
  }

  // Función para descifrar un texto cifrado en Base64 utilizando un IV.
  String decryptText(String encryptedText, String ivString) {
    final iv = encrypt.IV.fromBase64(ivString);
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    final decryptedText = encrypter.decrypt(encrypted, iv: iv);
    return decryptedText;
  }

  // Función para insertar una nota en la base de datos.
  Future<int?> insert(Notea note, int categoryId) async {
    final db = await _instance.db;
    final noteMap = note.toMap();
    final textToEncrypt = note.content;
    final random = Random.secure();
    final iv = encrypt.IV(Uint8List.fromList(
        List<int>.generate(16, (index) => random.nextInt(256))));
    noteMap['category_id'] = categoryId;
    noteMap['content'] = encryptText(textToEncrypt, iv);
    noteMap['iv'] = iv.base64; // Guarda el IV en la base de datos

    final insertedId = await db?.insert('notes', noteMap);

    // Verifica si la encriptación se realizó correctamente
    if (insertedId != null) {
      final noteFromDB =
      await db?.query('notes', where: 'id = ?', whereArgs: [insertedId]);
      if (noteFromDB != null && noteFromDB.isNotEmpty) {
        final encryptedContent = noteFromDB.first['content'] as String?;
        final ivString = noteFromDB.first['iv'] as String?;
        final decryptedText = decryptText(encryptedContent!, ivString!);
        if (decryptedText == textToEncrypt) {
          print('Encriptación exitosa: $textToEncrypt');
        } else {
          print('Error en la encriptación: $textToEncrypt');
        }
      }
    }

    return insertedId;
  }

  // Función para actualizar una nota en la base de datos.
  Future<int?> update(Notea note) async {
    final db = await _instance.db;
    final id = note.id;
    return await db
        ?.update('notes', note.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  // Función para eliminar una nota de la base de datos.
  Future<int?> delete(int id) async {
    final db = await _instance.db;
    return await db?.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
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