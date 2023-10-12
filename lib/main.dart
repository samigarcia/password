import 'package:app_2/src/app.dart';
import 'package:app_2/src/inicio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

//-------------importaciones de base de datos--------------------
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
      title: 'GESTOR DE PASSWORD',
      initialRoute: '/',
      routes: {
        '/': (context) => First(),
        '/segundo': (context) => const MyAppForm(),
        '/tercero': (context) => const MyInicio(),
      },
    );
  }
}

// ignore: must_be_immutable
class First extends StatelessWidget {
  //variables para la funcion de huella
  final LocalAuthentication _autenticacion = LocalAuthentication();
  bool authenticated = false;
  bool isAuthorized = false;
  String _autorizado = "No autorizado";
  //-----------------------------------

  First({super.key});

//configuracion de la base de datos--------------------------------------------------------------
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'user.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE usuario (id INT, name TEXT, password TEXT, rpassword TEXT, res TEXT)");
    }, version: 1);
  }
//-----------------------------------------------------------------------------------------------

//metodo para autenticarse con Huella o FaceID---------------------------------------------------
  // ignore: unused_element
  Future<void> _autorizar(BuildContext context) async {
    try {
      isAuthorized = await _autenticacion.authenticate(
        localizedReason: "Autentíquese para completar su transacción",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (isAuthorized == true) {
        authenticated = true;
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/tercero');
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }
//-----------------------------------------------------------------------------------------------

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
                child: const Text('Sing In o Sign Up'),
                onPressed: () async {
                  final Database database = await _openDB();
                  final int? cont;
                  //revisa si en la tabla 'usuario' haigan datos
                  cont = Sqflite.firstIntValue(
                      await database.rawQuery('SELECT COUNT(*) FROM usuario;'));
                  debugPrint('cantidad de personas: $cont');
                  //si hay datos quiere decir que ya se registro la persona
                  if (cont! > 1) {
                    // ignore: use_build_context_synchronously
                    _autorizar(context);
                    if (isAuthorized == true) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, '/tercero');
                    }
                  } else if (cont < 1) {
                    //si No hay datos, se manda a la pagina de registro
                    // ignore: use_build_context_synchronously
                    Navigator.pushNamed(context, '/segundo');
                  }
                }),
          ),
        ],
      ),
    );
  }
}
