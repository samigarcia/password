import 'package:app_2/src/app.dart';
import 'package:flutter/material.dart';

//-------------importaciones de base de datos--------------------
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as Path;
import 'package:app_2/db/persona.dart';
import 'src/inicio.dart';
//---------------------------------------------------------------

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REGISTRO',
      initialRoute: '/',
      routes: {
        '/': (context) => const First(),
        '/segundo': (context) => const MyAppForm(),
      },
    );
  }
}

class First extends StatelessWidget {
  //configuracion de la base de datos--------------------------------------------------------------
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'user.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE usuario (id INT, name TEXT, password TEXT, rpassword TEXT, res TEXT)");
    }, version: 1);
  }

  static contar() async {
    // final Database database = await _openDB();
    // final int? cont;
    // bool accion = false;
    // cont = Sqflite.firstIntValue(
    //     await database.rawQuery('SELECT COUNT(*) FROM usuario;'));
    // print('cantidad de personas: $cont');
    // if (cont! > 1) {
    //   accion = true;
    //   print(accion);
    //   Navigator.pushNamed(context, '/segundo');
    // } else {
    //   return cont;
    //    Navigator.push(context as BuildContext,
    //        MaterialPageRoute(builder: (context) => const MyAppForm()));
    // }
  }

  void initState() {}

//---------------------------------------------------------------------------------------------------
  const First({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('espera'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
                child: const Text('espera'),
                onPressed: () async {
                  final Database database = await _openDB();
                  final int? cont;
                  bool accion = false;
                  cont = Sqflite.firstIntValue(
                      await database.rawQuery('SELECT COUNT(*) FROM usuario;'));
                  print('cantidad de personas: $cont');
                  if (cont! > 1) {
                    accion = true;
                    print(accion);
                    // ignore: use_build_context_synchronously
                    Navigator.pushNamed(context, '/segundo');
                  }
                  contar();
                }),
          ),
        ],
      ),
    );
  }
}
