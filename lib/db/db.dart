import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_2/db/persona.dart';

class DB {
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'persona.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE usuario (id INT PRIMARY KEY AUTOINCREMENT, nombre TEXT, contra TEXT, rcontra TEXT,respuesta TEXT)");
    }, version: 1);
  }

  static Future<int> insert(Persona persona) async {
    Database database = await _openDB();
    return database.insert('usuario', persona.toMap());
  }

  static Future<int> delete(Persona persona) async {
    Database database = await _openDB();
    return database.delete('usuario', where: "id = ?", whereArgs: [persona.id]);
  }

  static Future<int> update(Persona persona) async {
    Database database = await _openDB();
    return database.update('usuario', persona.toMap(),
        where: "id = ?", whereArgs: [persona.id]);
  }

  static Future<List<Persona>> personas() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> personasMap =
        await database.query('usuario');
    return List.generate(
        personasMap.length,
        (i) => Persona(
            id: personasMap[i]['id'],
            name: personasMap[i]['nombre'],
            password: personasMap[i]['contra'],
            rpassword: personasMap[i]['rcontra'],
            res: personasMap[i]['respuesta']));
  }
}
