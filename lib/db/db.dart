import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_2/db/persona.dart';

class DB {
  static Future<String> getDatabaseName() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = join(databasesPath, 'persona.db');
    return databasePath;
  }
// Este metodo sirve para crear y/o llamar la base de datos ya creada y crea una tabla
//llamada usuario
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'persona.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE usuario (id INT, nombre TEXT, contra TEXT, rcontra TEXT,respuesta TEXT)");
    }, version: 1);
  }

// Un metodo que inserta datos a la tabla usuario
  static Future<int> insert(Persona persona) async {
    final databaseName = await DB.getDatabaseName();
    print('Nombre de la base de datos: $databaseName');

    Database database = await _openDB();
    return database.insert('usuario', persona.toMap());
  }

// Un metodo que eliomina a una persona de la tabla usuario
  static Future<int> delete(Persona persona) async {
    Database database = await _openDB();
    return database.delete('usuario', where: "id = ?", whereArgs: [persona.id]);
  }

// Un metodo que actualiza los datos ingresados por el usuario  a una persona de la tabla
  static Future<int> update(Persona persona) async {
    Database database = await _openDB();
    return database.update('usuario', persona.toMap(),
        where: "id = ?", whereArgs: [persona.id]);
  }

// Un metodo que enlista todos los adatos de la tabla usuario
  // static Future<List<Persona>> personas() async {
  //   Database database = await _openDB();
  //   final List<Map<String, dynamic>> personasMap =
  //       await database.query('usuario');
  //   return List.generate(
  //       personasMap.length,
  //       (i) => Persona(
  //           id: personasMap[i]['id'],
  //           name: personasMap[i]['nombre'],
  //           password: personasMap[i]['contra'],
  //           rpassword: personasMap[i]['rcontra'],
  //           res: personasMap[i]['respuesta']));
  // }

  // Un método que recupera e imprime todos los datos de la tabla
  static Future<List<Persona>> personas() async {
    final Database database = await _openDB();

    final List<Map<String, dynamic>> maps = await database.query('usuario');

    return List.generate(maps.length, (i) {
      return Persona(
          id: maps[i]['id'],
          name: maps[i]['nombre'],
          password: maps[i]['contra'],
          rpassword: maps[i]['rpassword'],
          res: maps[i]['respuesta']);
    });
  }
}
