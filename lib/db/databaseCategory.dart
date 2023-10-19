import 'package:app_2/Entity/notas.dart';
import 'package:app_2/Entity/categorias.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
import 'dart:typed_data';

class DataEncryptor {
  // Clave de 32 caracteres para cifrado AES
  static final key = Key.fromUtf8('my32lengthsupersecretnooneknows1');
  // Vector de inicialización (IV) de 16 bytes
  static final iv = IV.fromLength(16);
  // Instancia de Encrypter configurada con la clave AES
  static final encrypter = Encrypter(AES(key));

  String encryptText(String text, encrypt.IV iv) {
    // Asegúrate de que el texto tenga el tamaño correcto rellenándolo si es necesario
    final blockSize = 16; // Tamaño del bloque de cifrado para AES
    final paddedText = padTextForEncryption(text, blockSize);
    // Encripta el texto usando la clave y el IV proporcionados
    final encryptedText = encrypter.encrypt(paddedText, iv: iv);
    // Devuelve el texto encriptado como una cadena en formato Base64
    return encryptedText.base64;
  }

  // Método para agregar relleno al texto antes de cifrarlo
  String padTextForEncryption(String text, int blockSize) {
    // Calcula la longitud del relleno necesario para que el texto sea un
    // múltiplo del tamaño del bloque
    final paddingLength = blockSize - (text.length % blockSize);
    // Obtiene un carácter correspondiente a la longitud del relleno
    final paddingChar = String.fromCharCode(paddingLength);
    // Agrega el relleno al final del texto original
    final paddedText = text + paddingChar * paddingLength;
    // Devuelve el texto con el relleno agregado
    return paddedText;
  }

  String decryptText(String encryptedText, String ivString) {
    // Convierte el IV de Base64 a un objeto IV
    final iv = encrypt.IV.fromBase64(ivString);
    // Convierte el texto encriptado de Base64 a un objeto Encriptado
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    // Desencripta el texto utilizando la clave y el IV
    final decryptedText = encrypter.decrypt(encrypted, iv: iv);
    // Elimina el relleno después de la desencriptación
    final unpaddedText = unpadTextAfterDecryption(decryptedText);
    return unpaddedText;
  }

  String unpadTextAfterDecryption(String text) {
    // Obtiene la longitud del relleno del último carácter
    final paddingLength = text.codeUnitAt(text.length - 1);
    // Elimina el relleno y devuelve el texto original
    return text.substring(0, text.length - paddingLength);
  }
}

class DatabaseHelper {
  // Instancia única de la clase para el patrón Singleton.
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  // Fábrica para obtener la instancia única.
  factory DatabaseHelper() => _instance;

  // Variable para almacenar la base de datos.
  static Database? _db;

  // Función para obtener la ruta de la base de datos.
  // Future<String> getDatabaseName() async {
  //   final databasesPath = await getDatabasesPath();
  //   final path = join(databasesPath, '');
  //   return path;
  // }

  // Getter para obtener la base de datos.
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
    final path = join(databasesPath, 'gestorypassword.db');
    // Abre la base de datos o crea una nueva si no existe
    //return await openDatabase(path, version: 1, onCreate: _onCreate);
    return await openDatabase(path, version: 4, onCreate: _onCreate);
  }

  // Método para crear la tabla 'categories, images, notes' en la base de datos
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
        iv TEXT,
        category_id INTEGER,  -- Agrega una columna para la clave foránea
        FOREIGN KEY (category_id) REFERENCES categories (id)  -- Define la clave foránea
      )
    ''');

    await db.execute('''
    CREATE TABLE images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image_path TEXT
    )
    ''');
  }

  // Función para insertar una ruta de imagen en la bd sin eliminar
  Future<void> insertImageAssets(String imagePath) async {
    final db = await this.db;
    await db?.insert('images', {'image_path': imagePath});
  }

  // Función para insertar una ruta de imagen en la bd y elimina la anterior
  Future<void> insertImage(String imagePath) async {
    final db = await this.db;
    await db!.delete('images');
    await db.insert('images', {'image_path': imagePath});
  }

  // Función para insertar una categoría en la base de datos.
  Future<int> insertCategory(Category category) async {
    // Obtiene la instancia de la base de datos.
    final dbClient = await db;
    // Consulta la base de datos para verificar si ya existe una categoría con el mismo color.
    final existingCategories = await dbClient!.query(
      'categories',
      where: 'color = ?',
      whereArgs: [category.color],
    );
    if (existingCategories.isNotEmpty) {
      // Si ya existe una categoría con el mismo color,
      // retorna -1 para indicar que la inserción no se realizó.
      return -1;
    }
    // Inserta la categoría en la tabla 'categories' de la base de datos
    // utilizando los datos de la categoría representados en un mapa.
    return await dbClient.insert('categories', category.toMap());
  }

  // Función para obtener todas las categorías de la base de datos.
  Future<List<Category>> getCategories() async {
    final dbClient = await db; // Obtiene la instancia de la base de datos
    // Realiza una consulta a la tabla 'categories' para obtener todas las categorías.
    final list = await dbClient!.query('categories');
    // Mapea los resultados de la consulta a objetos de la
    // clase Category y los almacena en una lista.
    return list.map((json) => Category.fromMap(json)).toList();
  }

  // Función para actualizar una nota en la base de datos con su contenido desencriptado.
  Future<int?> updateDecryptedNote(Notea note, String decryptedText) async {
    final db = await _instance.db; // Obtiene la instancia de la base de datos.
    final noteMap = note.toMap(); // Convierte la nota en un mapa
    noteMap['content'] =
        decryptedText; // Actualiza el contenido con el texto desencriptado.
    // Realiza una actualización en la tabla 'notes' utilizando
    // el mapa de la nota y el ID de la nota específica.
    return await db
        ?.update('notes', noteMap, where: 'id = ?', whereArgs: [note.id]);
  }

  // Función para obtener todas las notas desencriptadas de la base de datos
  Future<List<Notea>> getAllNotes() async {
    final db = await _instance.db; // Obtiene la instancia de la base de datos.
    // Realiza una consulta para obtener las notas cifradas.
    final result = await db!.query('notes');
    // Instancia un DataEncryptor para descifrar las notas.
    final dataEncryptor = DataEncryptor();
    final noteMaps = result.map((json) {
      final content = json['content'] as String?;
      final iv = json['iv'] as String?;
      // Si el contenido y el IV existen, desencripta el texto.
      if (content != null && iv != null) {
        final decryptedText = dataEncryptor.decryptText(content, iv);
        // Actualiza el contenido desencriptado en el mapa de la nota.
        final updatedMap = Map<String, dynamic>.from(json);
        updatedMap['content'] = decryptedText;
        return updatedMap;
      }
      return json; // Devuelve el mapa original si no se realiza ninguna modificación
    }).toList();
    // Convierte los mapas de notas a objetos de notas y devuelve la lista de notas.
    final notes = noteMaps.map((noteMap) => Notea.fromMap(noteMap)).toList();
    return notes;
  }

  /*
  //Muestra sin desencriptar
  Future<List<Notea>> getAllNotes1() async {
    final db = await _instance.db;
    final result = await db!.query('notes');
    final notes = result.map((json) {
      return Notea.fromMap(json);
    }).toList();
    return notes;
  }*/

  // Función para insertar una nota en la base de datos.
  Future<int?> insert(Notea note, int categoryId) async {
    final db = await _instance.db; // Obtiene la instancia de la base de datos.
    final noteMap = note.toMap(); // Convierte la nota en un mapa.
    final textToEncrypt = note.content; // Texto a encriptar.
    final random = Random.secure();
    final iv = encrypt.IV(Uint8List.fromList(
        // Genera un IV aleatorio.
        List<int>.generate(16, (index) => random.nextInt(256))));
    // Asigna la categoría de la nota.
    noteMap['category_id'] = categoryId;
    // Crea una instancia de DataEncryptor para encriptar.
    final dataEncryptor = DataEncryptor();
    // Encripta el contenido de la nota.
    noteMap['content'] = dataEncryptor.encryptText(textToEncrypt, iv);
    // Guarda el IV en la base de datos.
    noteMap['iv'] = iv.base64; // Guarda el IV en la base de datos
    // Inserta la nota en la base de datos.
    final insertedId = await db?.insert('notes', noteMap);

    // Verifica si la encriptación se realizó correctamente
    if (insertedId != null) {
      final noteFromDB =
          await db?.query('notes', where: 'id = ?', whereArgs: [insertedId]);
      if (noteFromDB != null && noteFromDB.isNotEmpty) {
        final encryptedContent = noteFromDB.first['content'] as String?;
        final ivString = noteFromDB.first['iv'] as String?;
        final decryptedText =
            dataEncryptor.decryptText(encryptedContent!, ivString!);
        if (decryptedText == textToEncrypt) {
          print('Encriptación exitosa: $textToEncrypt');
        } else {
          print('Error en la encriptación: $textToEncrypt');
        }
      }
    }
    // Devuelve el ID de la nota insertada en la base de datos.
    return insertedId;
  }

  // Función para actualizar una nota en la base de datos.
  Future<int?> update(Notea note) async {
    final db = await _instance.db; // Obtiene la instancia de la base de datos.
    final id = note.id; // Obtiene el ID de la nota a actualizar.
    // Realiza la actualización en la base de datos y
    // devuelve la cantidad de registros actualizados.
    return await db
        ?.update('notes', note.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  // Función para eliminar una nota de la base de datos.
  Future<int?> delete(int id) async {
    final db = await _instance.db; // Obtiene la instancia de la base de datos.
    // Elimina una nota de la base de datos y devuelve
    // la cantidad de registros eliminados.
    return await db?.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
