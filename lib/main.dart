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
        centerTitle: true,
        title: const Text('INICIO DE SESION'),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
                width: 100.0,
                height: 40.0,
                child: ElevatedButton(
                    child: const Text('Log In'),
                    onPressed: () async {
                      Data.buscar(context);
                    })),
          ),
        ],
      ),
    );
  }
}
