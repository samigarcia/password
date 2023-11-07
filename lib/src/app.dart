//importaciones de paquetes de dart--------------
import 'package:app_2/db/db.dart';
import 'package:app_2/entity/persona.dart';
import 'package:flutter/material.dart';
//------------------------------------------------

//clase principal, la cual se manda a llamar desde el main
class MyAppForm extends StatefulWidget {
  const MyAppForm({super.key});
  @override
  State<MyAppForm> createState() => _MyAppFormState();
}

class _MyAppFormState extends State<MyAppForm> {
//variables para capturar los datos ingresados del usuario
  final userin = TextEditingController();
  final password = TextEditingController();
  final password1 = TextEditingController();
  final pregunta = TextEditingController();
  final respuesta = TextEditingController();
//--------------------------------------------------------

//variable para validar el formulario muy importante!
  final _keyForm = GlobalKey<FormState>();
  bool passwordVisible = true;
  bool passwordVisible2 = true;

//aqui empieza la creacion de los widgets
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
                    //se crea el color azul caracteristico de la parte de arriba
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
                                //son la decoracion del logo de registro
                                decoration: BoxDecoration(
                                  color: const Color(0xFF485876),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(65),
                                    bottomRight: Radius.circular(65),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(65),
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
                            alignment: AlignmentDirectional(0.30, 0.10),
                            child: Text(
                              'Registro',
                              style: TextStyle(
                                fontSize: 35.0,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          //se crea un box para el boton guardar
                          Align(
                            alignment: const AlignmentDirectional(-1.00, 0.80),
                            //Creacion del Boton de Guardar
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor:
                                    const Color.fromARGB(255, 43, 73, 245),
                              ),
                              child: const Text('Guardar'),
                              onPressed: () async {
                                //funcion que se activa al dar click
                                click();
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
                alignment: Alignment.topLeft,
                child: const Text(
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  'Usuario',
                ),
              ),
              //se crea el formulario de Registro
              Form(
                key: _keyForm,
                child: Column(
                  children: [
                    SizedBox(
                      child: TextFormField(
                        validator: (valor) {
                          if (valor!.isEmpty) {
                            return "campo vacio!";
                          }
                          return null;
                        },
                        controller: userin,
                        enableInteractiveSelection: false,
                        autofocus: true,
                        //textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
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
                      ),
                    ),
                    //divisor
                    const Divider(
                      height: 10.0,
                    ),
                    //se crea la etiqueta 'crear contraseña'
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                        'Crear contraseña',
                      ),
                    ),
                    //se crea la caja de texto donde se guarda la contraseña
                    SizedBox(
                      child: TextFormField(
                        validator: (valor1) {
                          if (valor1!.isEmpty) {
                            return "campo vacio!";
                          }
                          return null;
                        },
                        controller: password,
                        enableInteractiveSelection: false,
                        obscureText: passwordVisible,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            //passworddivisible
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                            //color: Colors.black,
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    //divisor
                    const Divider(
                      height: 10.0,
                    ),
                    //se crea la etiqueta 'Confirmar contraseña'
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                        'Confirmar contraseña',
                      ),
                    ),
                    //se crea la caja de texto donde se guarda la Re-contraseña
                    SizedBox(
                      child: TextFormField(
                        validator: (valor2) {
                          if (valor2!.isEmpty) {
                            return "campo vacio!";
                          } else if (valor2.compareTo(password.text) == 0) {
                            return null;
                          }
                          return "contraseña no coinside";
                        },
                        enableInteractiveSelection: false,
                        obscureText: passwordVisible2,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            //passworddivisible
                            icon: Icon(passwordVisible2
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                passwordVisible2 = !passwordVisible2;
                              });
                            },
                            //color: Colors.black,
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    //divisor
                    const Divider(
                      height: 10.0,
                    ),
                    // se crea el menu desplegable "dificil por cierto!"
                    DropdownMenu<String>(
                      width: 335,
                      controller: pregunta,
                      label: const Text('Selecciona una prengunta',
                          style: TextStyle(
                            color: Color.fromARGB(255, 10, 10, 10),
                          )),
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
                          debugPrint(value);
                        });
                      },
                      dropdownMenuEntries:
                          list.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                    //divisor
                    const Divider(
                      height: 10.0,
                    ),
                    //se crea la caja de texto donde se guarda la respuesta del usuario
                    SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        validator: (valor3) {
                          if (valor3!.isEmpty) {
                            return "campo vacio!";
                          }
                          return null;
                        },
                        controller: respuesta,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Respuesta',
                          hintStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //hace un llamado a insertar en la tabla persona-----------------
  insercion() async {
    Data.insert(Persona(
        id: 1,
        name: userin.text,
        password: password.text,
        rpassword: password1.text,
        pregunta: pregunta.text,
        res: respuesta.text));
    Navigator.pushNamed(context, '/tercero');
  }
//----------------------------------------------------

//metodo que se ejecuta al dar click en guardar----------
  click() {
    //validamos si el formulario tiene los datos completos
    if (_keyForm.currentState!.validate()) {
      debugPrint('Validacion del formulario');
      insercion();
    }
  }
//--------------------------------------------------------
}

//se crea las preguntas en forma de una lista
const List<String> list = [
  "nombre de su mascota",
  "comida favorita",
  "color favorito"
];
//variable que se encarga de poner la primera pregunta de la lista
String dropdownValue = list.first;
