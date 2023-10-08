import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_2/db/persona.dart';

import '../src/inicio.dart';

class DB {
// Este metodo sirve para crear y/o llamar la base de datos ya creada y crea una tabla llamada usuario
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'user.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE usuario (id INT, name TEXT, password TEXT, rpassword TEXT, res TEXT)");
    }, version: 1);
  }

  static Future<int> insert(Persona persona) async {
    try {
      Database database = await _openDB();
      int result = await database.insert('usuario', persona.toMap());
      print('Usuario insertado con éxito: $result');
      return result;
    } catch (e) {
      print('Error al insertar el usuario: $e');
      return -1; // Retorna un valor negativo en caso de error
    }
  }

// Un metodo que inserta datos a la tabla usuario
  static Future<int> inserto(Persona persona) async {
    Database database = await _openDB();
    return database.insert('usuario', persona.toMap());
  }

// Un metodo que elimina a una persona de la tabla usuario
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

  // Un método que recupera e imprime todos los datos de la tabla
  static Future<List<Persona>> personas() async {
    final Database database = await _openDB();

    final List<Map<String, dynamic>> maps = await database.query('usuario');

    print('personas total: ${maps.toString()}');

    return List.generate(maps.length, (i) {
      return Persona(
        id: maps[i]['id'],
        name: maps[i]['nombre'] ?? '', // Maneja valores nulos aquí
        password: maps[i]['contra'] ?? '', // Maneja valores nulos aquí
        rpassword: maps[i]['rcontra'] ?? '', // Maneja valores nulos aquí
        res: maps[i]['respuesta'] ?? '', // Maneja valores nulos aquí
      );
    });
  }

  static Future<String?> getPasswordForUser(int userId) async {
    final Database database = await _openDB();

    final List<Map<String, dynamic>> maps = await database.query(
      'usuario',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return maps.first['contra'] ?? '';
    }

    return null; // Retorna null si el usuario no se encuentra en la base de datos
  }

  static contar() async {
    final Database database = await _openDB();
    final int? cont;
    bool accion = false;
    //cont = (await database.rawQuery('select count(*) from usuario;')) as String;
    cont = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM usuario;'));
    print('cantidad de personas: $cont');
    if (cont! > 1) {
      accion = true;
      print(accion);
      // Navigator.push(
      //   context as BuildContext,
      //   MaterialPageRoute(builder: (context) => const MyInicio()),
      // );
    }
    return accion;
  }
}
