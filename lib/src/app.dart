//importaciones de paquetes de dart--------------
import 'package:app_2/db/db.dart';
import 'package:app_2/entity/persona.dart';
import 'package:flutter/material.dart';
import 'package:app_2/src/inicio.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
//------------------------------------------------

//clase principal, la cual se manda a llamar desde el main
class MyAppForm extends StatefulWidget {
  const MyAppForm({super.key});
  @override
  State<MyAppForm> createState() => _MyAppFormState();
}

class _MyAppFormState extends State<MyAppForm> {
  //inserccion hacia la labla persona
  insercion() async {
    Data.insert(Persona(
        id: 1,
        name: userin.text,
        password: password.text,
        rpassword: password1.text,
        res: respuesta.text));
  }

  //metodo que se ejecuta al dar click en guardar
  click() {
    //funcion donde se imprimen todas las personas
    cargaPersonas();
    //validamos si el formulario tiene los datos completos
    if (_keyForm.currentState!.validate()) {
      debugPrint('validacion del formulario');
      //funcion donde cheka si el dispositivo es compatible con datos biometricos
      _checkBiometrics();
      if (_canCheckBiometrics == true) {
        //funcion donde lista las autenticaciones disponibles
        _listaAutenticacionesDisponibles();
        //autenticacion solo con biometricos
        _autenticacionConBiometricos();
      } else {
        //funcion donde el S.O. determina el método de autenticación
        _authenticate();
      }
    } else {
      debugPrint('faltan datos del formulario');
    }
  }

  //varaibles para la autenticacion------------------------------------
  final LocalAuthentication auth = LocalAuthentication();
  // ignore: unused_field
  _SupportState _supportState = _SupportState.desconocido;
  // ignore: unused_field
  bool? _canCheckBiometrics;
  // ignore: unused_field
  List<BiometricType>? _availableBiometrics;
  // ignore: unused_field
  String _authorized = 'Not Authorized';
  // ignore: unused_field
  bool _isAuthenticating = false;

  final LocalAuthentication _autenticacion = LocalAuthentication();
  // ignore: unused_field
  final bool _podemosUsarAutorizacion = false;
  // ignore: unused_field
  final String _autorizado = "No autorizado";
  // ignore: unused_field
  List<BiometricType>? _autorizacionesDisponibles;
  //--------------------------------------------------------------------

  //variables para capturar los datos ingresados del usuario
  final userin = TextEditingController();
  final password = TextEditingController();
  final password1 = TextEditingController();
  final respuesta = TextEditingController();
  //--------------------------------------------------------

//funciones para la autenticacion #############################################

//esta funcion da a conocer los tipos datos biemetricos
  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      debugPrint("dispositivo compatible: ${canCheckBiometrics.toString()}");
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      // ignore: avoid_print
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

//este metodo enlista los tipos de metodos biometricos que tiene el dispositivo
  Future<void> _listaAutenticacionesDisponibles() async {
    late List<BiometricType> listaAutenticacion;
    try {
      listaAutenticacion = await _autenticacion.getAvailableBiometrics();
      debugPrint("Podemos usar: ${listaAutenticacion.toString()}");
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _autorizacionesDisponibles = listaAutenticacion = [];
    });
  }

//esta funcion accede al dato biometrico que contenga informacion del usuario
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Autenticacion';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Deje que el sistema operativo determine el método de autenticación',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      if (authenticated == true) {
        //funcion donde se guardan los datos en la DataBase
        insercion();
        //comentarios
        debugPrint('redirigiendose al Modulo de Inicio');
        //metodo para ir a otra pagina
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyInicio()),
        );
      }
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Autorizado' : 'No Autorizado');
  }

//esta funcion accede al dato biometrico Huella/FaceID para su autenticacion
  Future<void> _autenticacionConBiometricos() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Escanee su huella digital (o su rostro) para autenticarse',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated == true) {
        //funcion donde se guardan los datos en la DataBase
        insercion();
        //comentarios
        debugPrint('redirigiendose al Modulo de Inicio');
        //metodo para ir a otra pagina
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyInicio()),
        );
      }
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String mensaje = authenticated ? 'AUTORIZADO' : 'NO AUTORIZADO';
    setState(() {
      _authorized = mensaje;
    });
  }

//funcion que finaliza la autenticacion encaso de que el usuario se salga de la app, no la use
  Future<void> _cancelarAutenticacion() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.soportado
              : _SupportState.nosoportado),
        );
  }
// ############################################################################

//metood para ver todos los usuarios en la base de datos
  cargaPersonas() async {
    List<Persona> auxPersona = await Data.personas();
    setState(() {
      auxPersona;
    });
  }

//variable para validar el formulario muy importante!
  final _keyForm = GlobalKey<FormState>();

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
                            alignment: AlignmentDirectional(0.30, 0.10),
                            child: Text(
                              'Registro',
                              style: TextStyle(
                                fontSize: 40.0,
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
                margin: const EdgeInsets.only(right: 260),
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
              Form(
                key: _keyForm,
                child: Column(
                  children: [
                    SizedBox(
                      height: 45,
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
                    //un divizor
                    const Divider(
                      height: 15.0,
                    ),
                    //se crea la etiqueta 'crear contraseña'
                    Container(
                      margin: const EdgeInsets.only(right: 180.0),
                      child: const Text(
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
                      child: TextFormField(
                        validator: (valor) {
                          if (valor!.isEmpty) {
                            return "campo vacio!";
                          }
                          return null;
                        },
                        controller: password,
                        enableInteractiveSelection: false,
                        obscureText: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
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
                      ),
                    ),
                    //divizor
                    const Divider(
                      height: 15.0,
                    ),
                    //se crea la etiqueta 'Confirmar contraseña'
                    Container(
                      margin: const EdgeInsets.only(right: 150.0),
                      child: const Text(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                        'Confirmar contraseña',
                      ),
                    ),
                    //se crea el formulario donde se guarda la confirmacion de contraseña
                    SizedBox(
                      height: 45,
                      child: TextFormField(
                        validator: (valor) {
                          if (valor!.isEmpty) {
                            return "campo vacio!";
                          }
                          return null;
                        },
                        controller: password1,
                        enableInteractiveSelection: false,
                        obscureText: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
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
                      height: 45,
                      width: double.infinity,
                      child: TextFormField(
                        validator: (valor) {
                          if (valor!.isEmpty) {
                            return "campo vacio!";
                          }
                          return null;
                        },
                        controller: respuesta,
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
}

//se crea las preguntas en forma de una lista
const List<String> list = [
  "nombre de su mascota",
  "comida favorita",
  "color favorito"
];
//variable que se encarga de poner la primera pregunta de la lista
String dropdownValue = list.first;

//Metodo para la Autenticacion por Huella Dactilar
enum _SupportState {
  desconocido,
  soportado,
  nosoportado,
}
