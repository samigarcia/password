import 'dart:ffi';

import 'package:app_2/db/basedatos.dart';
import 'package:app_2/db/usuario.dart';

class UserDao {
  final database = DatabaseHelper.instance.db;

  Future<List<UserModel>> readAll() async {
    final data = await database.query('usuario');
    return data.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<int> insert(UserModel user) async {
    return await database.insert('usuario', {
      'nombre': user.name,
      'contra': user.password,
      'rcontra': user.rpassword,
      'respuesta': user.res
    });
  }
}
