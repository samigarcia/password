import 'package:flutter/material.dart';
import 'package:app_2/src/inicio.dart';

class MyAppForm extends StatefulWidget {
  const MyAppForm({super.key});

  @override
  State<MyAppForm> createState() => _MyAppFormState();
}

class _MyAppFormState extends State<MyAppForm> {
  String _user = "";
  String _password = "";
  String _password1 = "";
  String _respuesta = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 245, 245),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
        children: <Widget>[
          Column(
            children: [
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                        children: [
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
                                      builder: (context) => MyInicio()),
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
              const Divider(
                height: 15.0,
              ),
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
              const Divider(
                height: 15.0,
              ),
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
              const Divider(
                height: 15.0,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: TextField(
                  enabled: false,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'seleciona una pregunta',
                    suffixIcon: Icon(
                      Icons.navigate_next,
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onSubmitted: (valor) {
                    debugPrint('la respuesta es: $_respuesta');
                  },
                ),
              ),
              const Divider(
                height: 15.0,
              ),
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
