//-----------------importaciones----------------------------
import 'package:app_2/src/app.dart';
import 'package:app_2/src/inicio.dart';
import 'package:app_2/src/note.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:app_2/db/db.dart';
import 'package:flutter/services.dart';
//----------------------------------------------------------

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    //inicializa el tema que este activado
    final initialMode = brightness == Brightness.dark
        ? AdaptiveThemeMode.dark
        : AdaptiveThemeMode.light;
    // Devuelve un AdaptiveTheme, que permite cambiar entre temas oscuros y claros
    return AdaptiveTheme(
      // Tema oscuro
      dark: ThemeData.dark(),
      // Tema claro
      light: ThemeData.light(),
      // Modo de tema inicial
      initial: initialMode,
      // Builder que configura el tema en función del AdaptiveTheme
      builder: (theme, darkTheme) {
        // Devuelve un MaterialApp que utiliza el tema proporcionado
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GESTOR DE PASSWORD',
          theme: theme,
          darkTheme: darkTheme,
          //creamos un router para movernos entre pages----
          initialRoute: '/',
          routes: {
            '/': (context) => const First(),
            '/segundo': (context) => const MyAppForm(),
            '/tercero': (context) => const MyHomePage(),
            '/notes': (context) => NoteScreen(),
          },
        );
      },
    );
  }
}

//clase principal que se ejecuta al abrir la aplicacion
class First extends StatelessWidget {
  const First({super.key});

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '¿Salir de la aplicación?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                      child: const Text(
                        'Salir',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Cierra la aplicación por completo
        _showExitConfirmationDialog(context);
        return true; // Si retornas false, impedirá la navegación hacia atrás.
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('INICIO DE SESION'),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
            ),
            onPressed: () {
              // Cierra la aplicación por completo
              _showExitConfirmationDialog(context);
            },
          ),
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
      ),
    );
  }
}
