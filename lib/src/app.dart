//importaciones de paquetes de dart
import 'package:app_2/values/temas.dart';
import 'package:flutter/material.dart';
import 'package:app_2/src/inicio.dart';
import 'package:sqflite/sqflite.dart';

//clase principal, se manda a llamar desde el main
class MyAppForm extends StatefulWidget {
  const MyAppForm({super.key});
  @override
  State<MyAppForm> createState() => _MyAppFormState();
}

class _MyAppFormState extends State<MyAppForm> {
  //iniciamos la instancia db para usar los metodos del archivo "basedatos.dart"
  //LlamandoDatabase db = LlamandoDatabase();

  //variables para capturar los datos ingresados del usuario
  String _user = "";
  String _password = "";
  String _password1 = "";
  String _respuesta = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //el color de toda la pantalla 'blanco'
      backgroundColor: const Color.fromARGB(255, 247, 245, 245),
      //se crea la vista principal
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
        children: <Widget>[
          Column(
            //se crea una lista de witgets
            children: [
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  //se crea otra lista de witgets
                  children: [
                    //se crea el color azol de la parte de arriba
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6BA0E3), Color(0xFF2874CF)],
                          stops: [0, 1],
                          begin: AlignmentDirectional(0.1, -1),
                          end: AlignmentDirectional(-0.1, 1),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(400),
                          bottomRight: Radius.circular(70),
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                      ),
                      child: Stack(
                        //se crea otra lista de widgets
                        children: [
                          //se crea el contorno y le logo del refgistro de usuario
                          Align(
                            alignment: const AlignmentDirectional(-1, 0.14),
                            child: Container(
                                width: 110,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF485876),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(70),
                                    bottomRight: Radius.circular(70),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(70),
                                  ),
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                    color: const Color(0xFF485876),
                                  ),
                                ),
                                child: const Align(
                                  alignment: AlignmentDirectional(-0.93, -0.65),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8, 8, 8, 8),
                                    child: Icon(
                                      Icons.admin_panel_settings_outlined,
                                      color: Color(0xFF0096F9),
                                      size: 60,
                                    ),
                                  ),
                                )),
                          ),
                          //le agregamos 'Registro' al tema de color azul
                          const Align(
                            alignment: AlignmentDirectional(0.14, 0.07),
                            child: Text(
                              'Registro',
                              style: TextStyle(
                                fontSize: 40.0,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          //se crea el boton guardar
                          Align(
                            alignment: const AlignmentDirectional(-1.00, 0.80),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor:
                                    const Color.fromARGB(255, 43, 73, 245),
                              ),
                              child: const Text('Guardar'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyInicio()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //se crea la etiqueta usuario
              Container(
                margin: const EdgeInsets.only(right: 280),
                child: const Text(
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  'Usuario',
                ),
              ),
              //se crea la caja de texto donde contendra el usuario
              SizedBox(
                height: 45,
                child: TextField(
                  enableInteractiveSelection: false,
                  autofocus: true,
                  //textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Ingrese su Usuario',
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                    suffixIcon: Icon(
                      Icons.verified_user,
                      color: Colors.black,
                    ),
                  ),
                  onSubmitted: (valor) {
                    _user = valor;
                    debugPrint('el nombre es: $_user');
                  },
                ),
              ),
              //un divizor
              const Divider(
                height: 15.0,
              ),
              //se crea la etiqueta 'crear contraseña'
              Container(
                margin: const EdgeInsets.only(right: 210),
                child: const Text(
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  'Crear contraseña',
                ),
              ),
              //se crea la caja de texto donde contendra la contraseña
              SizedBox(
                height: 45,
                child: TextField(
                  enableInteractiveSelection: false,
                  obscureText: true,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.black,
                    ),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                  onSubmitted: (valor) {
                    _password = valor;
                    debugPrint('la contraseña es: $_password');
                  },
                ),
              ),
              //divizor
              const Divider(
                height: 15.0,
              ),
              //se crea la etiqueta 'Confirmar contraseña'
              Container(
                margin: const EdgeInsets.only(
                  right: 170,
                ),
                child: const Text(
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  'Confirmar contraseña',
                ),
              ),
              //se crea la caja de texto donde se guarda la confirmacion de contraseña
              SizedBox(
                height: 45,
                child: TextField(
                  enableInteractiveSelection: false,
                  obscureText: true,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.black,
                    ),
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onSubmitted: (valor1) {
                    _password1 = valor1;
                    debugPrint('la confirmacion de contraseña es: $_password1');
                  },
                ),
              ),
              //divisor
              const Divider(
                height: 10.0,
              ),
              // se crea el menu desplegable "dificil por cierto!"
              DropdownMenu<String>(
                width: 350,
                label: const Text('Selecciona una prengunta'),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                  fillColor: Colors.black,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.black,
                  fontSize: 20,
                ),
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                dropdownMenuEntries:
                    list.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
              //divisor
              const Divider(
                height: 10.0,
              ),
              //se crea la caja de texto donde se guarda la respuesta del usuario
              SizedBox(
                height: 45,
                width: double.infinity,
                child: TextField(
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Respuesta',
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onSubmitted: (valor) {
                    _respuesta = valor;
                    debugPrint('la respuesta es: $_respuesta');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//se crea las preguntas en forma de una lista
const List<String> list = [
  "nombre de su mascota",
  "comida favorita",
  "color favorito"
];
//variable que se encarga de poner la primera pregunta de la lista "no lo use!"
String dropdownValue = list.first;
