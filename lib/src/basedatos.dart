import 'package:sqflite/sqflite.dart';
import 'dart:async';

class Task {}

class LlamandoDatabase {
  late Database _db;

  String sql =
      "CREATE TABLE usuario (id INT  PRIMARY KEY, nombre TEXT, contra TEXT, rcontra TEXT, respuesta TEXT)";

  initDB() async {
    _db = await openDatabase('mi_database.db',
        version: 1, onCreate: (Database db, int version) => {db.execute(sql)});
  }
}
