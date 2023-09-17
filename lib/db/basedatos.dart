import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DatabaseHelper {
  static DatabaseHelper? _databasehelper;
  DatabaseHelper._internal();
  static DatabaseHelper get instance =>
      _databasehelper ??= DatabaseHelper._internal();

  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    _db = await openDatabase('datos.db', version: 1, onCreate: (db, version) {
      db.execute(
          "CREATE TABLE usuario (id INT PRIMARY KEY AUTOINCREMENT, nombre TEXT, contra TEXT, rcontra TEXT,respuesta TEXT)");
    });
  }
}

// class Task {
//   String nombre = "";

//   Task(this.nombre);

//   Map<String, dynamic> toMap() {
//     return {
//       //nombre de la base de datos => "nombre" y nombre de la clase 'nombre'
//       "nombre": nombre,
//     };
//   }

//   Task.fromMap(Map<String, dynamic> map) {
//     nombre = map['nombre'];
//   }

//   //getter and setter
//   String get getNombre => nombre;
//   set setNombre(String nombre) => this.nombre = nombre;
// }

// class LlamandoDatabase {
//   late Database _db;

//   String sql =
//       "CREATE TABLE usuario (id INT PRIMARY KEY, nombre TEXT, contra TEXT, rcontra TEXT,respuesta TEXT)";

//   initDB() async {
//     _db = await openDatabase('mi_database.db',
//         version: 1, onCreate: (Database db, int version) => {db.execute(sql)});
//   }

//   //metodo para insertar los datos de usuario
//   insert(Task task) async {
//     _db.insert('usuario', task.toMap());
//   }

//   Future<Iterable<Task>> getAllTasks() async {
//     List<Map<String, dynamic>> results = await _db.query('usuario');

//     return results.map((map) => Task.fromMap(map));
//   }
// }
