//-----------------importaciones----------------------------
import 'package:app_2/src/app.dart';
import 'package:app_2/src/inicio.dart';
import 'package:flutter/material.dart';
import 'package:app_2/db/db.dart';
//----------------------------------------------------------

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
      //creamos un router para movernos entre pages----
      initialRoute: '/',
      routes: {
        '/': (context) => const First(),
        '/segundo': (context) => const MyAppForm(),
        '/tercero': (context) => const MyInicio(),
      },
      //-----------------------------------------------
    );
  }
}

//clase principal que se ejecuta al abrir la aplicacion
class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INICIO DE SESION'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
                child: const Text('Inicia Sesion'),
                onPressed: () async {
                  Data.buscar(context);
                }),
          ),
        ],
      ),
    );
  }
}
