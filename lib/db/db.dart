import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_2/entity/persona.dart';

//variables para la funcion de huella----------------------------
final LocalAuthentication _autenticacion = LocalAuthentication();
bool isAuthorized = false;
//---------------------------------------------------------------

class Data {
// Este metodo sirve para crear y/o llamar la base de datos ya creada y crea una tabla llamada usuario
  static Future<Database> _openDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'user.db');
    return await openDatabase(path, version: 4, onCreate: _onCreate);
  }

//metodo donde se crea la tabla con execute y se lo enviamos a _openDB()
  static void _onCreate(Database db, int newVersion) async {
    String sql =
        "CREATE TABLE usuario (id INT, name TEXT, password TEXT, rpassword TEXT, res TEXT)";
    await db.execute(sql);
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

    print('todas las personas: ${maps.toString()}');

    return List.generate(maps.length, (i) {
      return Persona(
        id: maps[i]['id'],
        name: maps[i]['name'] ?? '', // Maneja valores nulos aquí
        password: maps[i]['password'] ?? '', // Maneja valores nulos aquí
        rpassword: maps[i]['rpassword'] ?? '', // Maneja valores nulos aquí
        res: maps[i]['res'] ?? '', // Maneja valores nulos aquí
      );
    });
  }

//este metodo busca en la base de datos el id que le demos.
  static Future<String?> getPasswordForUser(int userId) async {
    final Database database = await _openDB();

    final List<Map<String, dynamic>> maps = await database.query(
      'usuario',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return maps.first['password'] ?? '';
    }

    return null; // Retorna null si el usuario no se encuentra en la base de datos
  }

//este metodo cheka en la base de datos si hay registro de usuario
  static buscar(BuildContext context) async {
    final Database database = await _openDB();
    final int? cont;
    String sql = "SELECT COUNT(*) FROM usuario;";
    //revisa que en la tabla 'usuario' haigan datos
    cont = Sqflite.firstIntValue(await database.rawQuery(sql));
    print('cantidad de personas: $cont');
    //si hay datos quiere decir que ya se registro un usuario
    if (cont! > 0) {
      // ignore: use_build_context_synchronously
      _autorizar(context);
    } else if (cont < 1) {
      //si No hay datos, se manda a la pagina de registro
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/segundo');
    }
  }

  //metodo para autenticarse con Huella o FaceID----------------------
  static Future<void> _autorizar(BuildContext context) async {
    try {
      isAuthorized = await _autenticacion.authenticate(
        localizedReason: "Autentíquese para saber su Identidad",
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      if (isAuthorized == true) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/tercero');
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }
//------------------------------------------------------------------
}
