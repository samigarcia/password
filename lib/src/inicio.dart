import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../db/databaseCategory.dart';
import '../Entity/notas.dart';
import '../Entity/categorias.dart';
import 'note.dart';
import '../db/db.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

//widget que puede cambiar de estado a lo largo del tiempo
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File? _image; // Variable para almacenar una imagen (puede ser nula)
  int _selectedChipIndex =
      -1; // Índice de la categoría seleccionada (inicializado en -1)
  List<Category> _categories = []; // Lista para almacenar categorías
  List<Notea> _notes = []; //Lista para almacenar notas

  // Variable de tipo String para almacenar una ruta de imagen (puede ser nula)
  String? _imagePathFromDatabase;
  //se utiliza como bandera para verificar si la imagen fue guardada
  bool _imageSaved = false;
  // Variable para controlar si la imagen ya ha sido guardada
  bool _imageAlreadySaved = false;

  // Método que se llama al inicializar el estado
  @override
  void initState() {
    // Llama al método initState de la clase base
    super.initState();
    // Llama al método retrieveAndPrintImage
    if (!_imageSaved) {
      saveImageFromAssetToDatabase().then((_) {
        retrieveAndPrintImage();
        setState(() {
          // Marca la imagen como guardada después de ejecutar una vez
          _imageSaved = true;
        });
      });
    }
    // Llama al método _loadCategories al iniciar la pantalla
    _loadCategories();
    _loadNotes();
  }

  //carga las categorias de la bd
  void _loadCategories() async {
    // Instancia de DatabaseHelper para interactuar con la base de datos
    final dbHelper = DatabaseHelper();
    //evuelve una lista de categorías
    final categories = await dbHelper.getCategories();

    setState(() {
      // Actualiza la lista de categorías con las categorías cargadas desde la bd
      _categories = categories;
    });
  }

  //carga las notas de la bd
  void _loadNotes() async {
    try {
      final dbHelper = DatabaseHelper();
      // Obtiene todas las notas desde la base de datos.
      final notes = await dbHelper.getAllNotes();
      setState(() {
        // Actualiza la lista de notas en el estado del widget.
        _notes = notes;
      });
    } catch (e) {
      print('Error al cargar notas: $e');
    }
  }

  Future<void> retrieveAndPrintImage() async {
    final db = await DatabaseHelper().db;
    // Consulta la base de datos para obtener la lista de imágenes.
    final List<Map<String, dynamic>> imageList = await db!.query('images');

    if (imageList.isNotEmpty) {
      // Obtiene la ruta de la primera imagen de la lista.
      final imagePath = imageList.first['image_path'] as String;

      // Cargar la imagen desde la ruta de la base de datos
      final imageFile = File(imagePath);

      if (imageFile.existsSync()) {
        // Leer los bytes de la imagen y mostrarlos en la consola como una cadena
        final imageBytes = await imageFile.readAsBytes();
        final imageBase64 = base64Encode(imageBytes);

        print('Imagen guardada en la base de datos a Base64: $imageBase64');

        //Asigna la ruta de la imagen directamente a _imagePathFromDatabase
        //Activa un cambio en la interfaz de usuario para reflejar la nueva imagen
        setState(() {
          _imagePathFromDatabase = imagePath;
        });
      } else {
        print('La imagen no existe en la ruta de la base de datos: $imagePath');
      }
    } else {
      print('No se encontraron imágenes en la base de datos.');
    }
  }

  // Captura una imagen desde la cámara y la guarda en la base de datos
  Future<void> _getImageFromCamera() async {
    // Instancia de ImagePicker para capturar imágenes
    final picker = ImagePicker();
    // Captura una imagen desde la cámara
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Si se capturó una imagen con éxito
      setState(() {
        // Asigna la imagen capturada a la variable _image
        _image = File(pickedFile.path);
        _imagePathFromDatabase = _image?.path;
      });

      // Obtén la instancia de DatabaseHelper y luego inserta la imagen
      final databaseHelper = DatabaseHelper();
      // Instancia de DatabaseHelper para interactuar con la base de datos
      final imagePath = _image?.path;
      //await databaseHelper.printImagesInDatabase();

      try {
        // Inserta la ruta de la imagen en la base de datos
        await databaseHelper.insertImage(imagePath!);
        print("Imagen guardada con exito");
      } catch (e) {
        print('Error al insertar la imagen en la base de datos: $e');
      }
    }
  }

  // Selecciona una imagen desde la galería y la guarda en la base de datos
  Future<void> _getImageFromGallery() async {
    // Instancia de ImagePicker para seleccionar imágenes de la galería
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // Selecciona una imagen desde la galería
    if (pickedFile != null) {
      //Si se seleccionó una imagen con éxito
      setState(() {
        // Asigna la imagen seleccionada a la variable _image
        _image = File(pickedFile.path);
        _imagePathFromDatabase = _image?.path;
      });

      // Obtén la instancia de DatabaseHelper y luego inserta la imagen
      // Instancia de DatabaseHelper para interactuar con la base de datos
      final databaseHelper = DatabaseHelper();
      // Obtiene la ruta de la imagen seleccionada
      final imagePath = _image?.path;

      try {
        // Inserta la ruta de la imagen en la base de datos
        await databaseHelper.insertImage(imagePath!);
      } catch (e) {
        print('Error al insertar la imagen en la base de datos: $e');
      }
    }
  }

  //funcion para guardar la imagen en la bd
  Future<void> saveImageFromAssetToDatabase() async {
    if (_imageAlreadySaved) {
      print('La imagen ya se ha guardado anteriormente, no se agregará.');
      return; // Sale del método si la imagen ya ha sido guardada previamente.
    } else {
      try {
        // Carga los datos de la imagen desde los activos.
        final ByteData assetData = await rootBundle.load('assets/imagen.jpg');
        // Convierte los datos de la imagen en una lista de bytes.
        final List<int> bytes = assetData.buffer.asUint8List();

        final documentsDirectory = await getApplicationDocumentsDirectory();
        // Establece la ubicación de almacenamiento de la imagen en la carpeta
        // de documentos de la aplicación.
        final imagePath = path.join(documentsDirectory.path, 'imagen.jpg');
        // Guarda la imagen en la ubicación especificada.
        await File(imagePath).writeAsBytes(bytes);

        final databaseHelper = DatabaseHelper();
        // Inserta la ruta de la imagen en la base de datos.
        await databaseHelper.insertImageAssets(imagePath);

        // Marca la imagen como guardada
        _imageAlreadySaved = true;

      } catch (e) {
        print('Error al guardar la imagen en la base de datos: $e');
      }
    }
  }


  // Función para mostrar Opciones de foto de perfil
  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.center,
            child: Text('Opciones Foto de Perfil',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              )
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera, color: Colors.blue),
                title: Text(
                  'Tomar una foto',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromCamera();
                },
              ),
              Divider(thickness: 1),
              ListTile(
                leading: Icon(Icons.photo, color: Colors.green),
                title: Text(
                  'Seleccionar desde la galería',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromGallery();
                },
              ),
              Divider(thickness: 1),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/');
                },
              ),
              Divider(thickness: 1),
              ListTile(
                leading: Icon(Icons.home, color: Colors.orange),
                title: Text(
                  'Regresar a la pantalla de inicio',
                  style: TextStyle(fontSize: 16, color: Colors.orange),
                ),
                onTap: () {
                  // Navegar a la pantalla de inicio
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Funcion para listar las notas por categoria
  List<Notea> getNotesForSelectedCategory() {
    if (_selectedChipIndex == -1) {
      // Si no se ha seleccionado ninguna categoría, devuelve todas las notas
      return _notes;
    } else {
      // Filtra las notas por la categoría seleccionada
      final selectedCategory = _categories[_selectedChipIndex];
      return _notes
          .where((note) => note.categoryId == selectedCategory.id)
          .toList();
    }
  }

  //funcion para que el contenido se muestre en asteriscos
  String hideText(String text, {int defaultLength = 12}) {
    return '* ' * (defaultLength);
  }


  // Función para pedir la contraseña al usuario
  Future<void> _showPasswordDialog(BuildContext context, Notea note) async {
    // ocultar y mostrar la contraseña del campo
    bool obscureText1 = true;
    // Crear un controlador de texto para la contraseña.
    final TextEditingController passwordController = TextEditingController();
    // Contador para rastrear los intentos incorrectos de contraseña.
    int incorrectPasswordAttempts = 0;
    // Crear un StreamController para manejar mensajes de error.
    final StreamController<String> errorStreamController = StreamController<String>();

    showDialog(
      context: context,
      // Mostrar un diálogo cuando se llama a _showPasswordDialog.
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Utilizar StatefulBuilder para mantener el estado del diálogo.
          builder: (context, setState) {
            return Center(
              child: SingleChildScrollView(
                child: AlertDialog(
                  title: Text("Ingrese la contraseña con la que se registró"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      StreamBuilder<String>(
                        stream: errorStreamController.stream,
                        builder: (context, snapshot) {
                          return TextField(
                            // Asociar el controlador de texto al campo de contraseña.
                            controller: passwordController,
                            // Configurar la visibilidad de la contraseña del primer campo.
                            obscureText: obscureText1,
                            decoration: InputDecoration(
                              labelText: "Contraseña",
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText1 ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  // Cambiar la visibilidad de la contraseña
                                  // del campo
                                  setState(() {
                                    obscureText1 = !obscureText1;
                                  });
                                },
                              ),
                              // Mostrar el mensaje de error en función
                              // del estado del Stream.
                              errorText: snapshot.data,
                              errorStyle: TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Cerrar el diálogo al presionar "Cancelar".
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Obtener la contraseña del usuario desde los datos.
                        String? userPassword = await Data.getPasswordForUser();
                        // Obtener la contraseña ingresada por el usuario.
                        final enteredPassword = passwordController.text;

                        if (userPassword != null && enteredPassword == userPassword) {
                          // Cerrar el diálogo y mostrar el contenido de la nota.
                          Navigator.of(context).pop();
                          _showNoteContentDialog(context, note);
                        } else {
                          incorrectPasswordAttempts++;

                          if (incorrectPasswordAttempts >= 3) {
                            // Mostrar ventana de recuperación de contraseña si se
                            // excede el número de intentos incorrectos.
                            _showRecoveryDialog(context);
                            Navigator.of(context).pop();
                          } else {
                            // Actualizar el mensaje de error.
                            errorStreamController.add("Contraseña incorrecta");
                            // Limpiar el campo de contraseña para un nuevo intento.
                            passwordController.clear();
                          }
                        }
                      },
                      child: Text(
                        "Aceptar",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //Funcion para responder pregunta de seguridad
  void _showRecoveryDialog(BuildContext context) async {
    // Crear un controlador de texto para la respuesta a la pregunta de recuperación.
    final TextEditingController recoveryQuestionController = TextEditingController();
    // Obtener la pregunta de seguridad del usuario.
    String? userAsk = await Data.getAskForUser();
    // Obtener la respuesta a la pregunta de seguridad del usuario.
    String? userAnswer = await Data.getAnswerForUser();
    // Variable para rastrear si la respuesta es incorrecta.
    bool isAnswerIncorrect = false;
    // Crear un StreamController para manejar mensajes de error.
    final StreamController<String> errorStreamController = StreamController<String>();

    showDialog(
      context: context,
      // Mostrar un diálogo cuando se llama a _showRecoveryDialog.
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              title: Text("Recuperación de contraseña"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  StreamBuilder<String>(
                      stream: errorStreamController.stream,
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Text("Intentos excedidos. Responda la pregunta de seguridad"),
                            SizedBox(height: 10),
                            TextField(
                              // Asociar el controlador de texto al campo de respuesta.
                              controller: recoveryQuestionController,
                              decoration: InputDecoration(
                                // Utilizar la pregunta de seguridad como etiqueta.
                                labelText: userAsk,
                                border: OutlineInputBorder(
                                  // Cambiar el color del borde si la respuesta es incorrecta.
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                // Mostrar el mensaje de error en función del estado del Stream.
                                errorText: snapshot.data,
                                errorStyle: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Cerrar el diálogo al presionar "Cancelar".
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                  // Aquí puedes manejar la respuesta a la pregunta de recuperación
                    // Obtener la respuesta ingresada por el usuario.
                    String recoveryAnswer = recoveryQuestionController.text;
                    // Realiza la validación de la respuesta y la recuperación de la contraseña
                    // Compara la respuesta con la respuesta del usuario.
                    if (recoveryAnswer == userAnswer) {
                      // Mostrar el diálogo de cambio de contraseña.
                      _showNewPassDialog(context);
                      // Cerrar el diálogo de recuperación.
                      Navigator.of(context).pop();
                    } else {
                      // Actualizar el mensaje de error si la respuesta es incorrecta.
                      errorStreamController.add("Respuesta incorrecta");
                      // Limpiar el campo de respuesta para un nuevo intento.
                      recoveryQuestionController.clear();
                    }
                  },
                  child: Text(
                    "Aceptar",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Funcion para actualiza la contraseña
  void _showNewPassDialog(BuildContext context) async {
    // Crear un controlador de texto para el primer campo de contraseña.
    final TextEditingController passController = TextEditingController();
    // Crear un controlador de texto para el segundo campo de contraseña.
    final TextEditingController pass2Controller = TextEditingController();
    String? userAnswer = await Data.getAskForUser();
    bool obscureText1 = true; // ocultar y mostrar la contraseña del primer campo
    bool obscureText2 = true; // ocultar y mostrar la contraseña del segundo campo
    // Crear un StreamController para manejar los mensajes de error del primer campo.
    final StreamController<String> errorStreamController = StreamController<String>();
    // Crear un StreamController para manejar los mensajes de error del segundo campo.
    final StreamController<String> errorStreamController2 = StreamController<String>();

    showDialog(
      context: context,
      // Mostrar un diálogo cuando se llama a _showNewPassDialog.
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Utilizar StatefulBuilder para mantener el estado del diálogo.
          builder: (context, setState) {
            return Center(
              child: SingleChildScrollView(
                child: AlertDialog(
                  title: Center(child: Text("Nueva Contraseña")),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StreamBuilder<String>(
                        stream: errorStreamController.stream,
                        builder: (context, snapshot) {
                          return Column(
                            children: [
                              Text("Ingrese su nueva contraseña"),
                              SizedBox(height: 10),
                              TextField(
                                // Asociar el controlador de texto al campo de contraseña.
                                controller: passController,
                                // Configurar la visibilidad de la contraseña del primer campo.
                                obscureText: obscureText1,
                                decoration: InputDecoration(
                                  labelText: "Contraseña",
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscureText1 ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      // Cambiar la visibilidad de la contraseña del primer campo
                                      setState(() {
                                        obscureText1 = !obscureText1;
                                      });
                                    },
                                  ),
                                  // Mostrar el mensaje de error en función del estado del Stream.
                                  errorText: snapshot.data,
                                  errorStyle: TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                      StreamBuilder<String>(
                        stream: errorStreamController2.stream,
                        builder: (context, snapshot) {
                          return TextField(
                            // Asociar el controlador de texto al campo de confirmación de contraseña.
                            controller: pass2Controller,
                            // Configurar la visibilidad de la contraseña del segundo campo.
                            obscureText: obscureText2,
                            decoration: InputDecoration(
                              labelText: "Confirme su contraseña",
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText2 ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  // Cambiar la visibilidad de la contraseña del segundo campo
                                  setState(() {
                                    obscureText2 = !obscureText2;
                                  });
                                },
                              ),
                              // Mostrar el mensaje de error en función del estado del Stream.
                              errorText: snapshot.data,
                              errorStyle: TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Cerrar el diálogo al presionar "Cancelar".
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Obtener el valor del primer campo de contraseña.
                        String newPassword = passController.text;
                        // Obtener el valor del segundo campo de confirmación de contraseña.
                        String confirmPassword = pass2Controller.text;

                        if (newPassword.isEmpty) {
                          // Actualizar el mensaje de error del primer campo si está vacío.
                          errorStreamController.add("Campo Vacio");
                          if (confirmPassword.isEmpty) {
                            // Actualizar el mensaje de error del segundo campo si está vacío.
                            errorStreamController2.add("Campo Vacio");
                          }
                        } else if (newPassword == confirmPassword) {
                          // Actualizar la contraseña en la base de datos si las contraseñas coinciden.
                          Data.updatePasswordAndRPassword(newPassword, confirmPassword);
                          // Cierra la ventana de nueva contraseña
                          Navigator.of(context).pop();
                          // Mostrar un mensaje de éxito y cargar las notas desde la base de datos.
                          Fluttertoast.showToast(
                            msg: 'Contraseña Actualizada con éxito',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                        } else {
                          // Actualizar el mensaje de error si las contraseñas no coinciden
                          errorStreamController.add("Contraseñas no coinciden");
                          // Actualizar el mensaje de error en el segundo campo si las contraseñas no coinciden.
                          errorStreamController2.add("Contraseñas no coinciden");
                        }
                      },
                      child: Text(
                        "Aceptar",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //funcion para visualizar el contenido de la nota
  void _showNoteContentDialog(BuildContext context, Notea note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //ventana para visualizar datos de la nota
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,//color
          // contenedor del dialogo
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: catColor.getColorByIndex(note.categoryId),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    note.title,//datos del titulo de la nota
                    style: TextStyle(
                      color: Colors.black,//color asignado
                      fontSize: 22,//tamaño del texto
                      fontWeight: FontWeight.bold,//tipo de fuente (letra)
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey,//color del divisor
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    note.content,//datos del contenido de la nota
                    style: TextStyle(
                      color: Colors.black,//color asignado
                      fontSize: 16, //tamaño del texto
                      fontWeight: FontWeight.normal, //tipo de fuente (letra)
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    //cierra la ventana
                    Navigator.of(context).pop();
                  },
                  //Texto cerrar del boton
                  child: Text(
                    "Cerrar",
                    style: TextStyle(
                      color: Colors.blue,//asignacion de color
                      fontSize: 18,//tamaño de letra
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Crear una instancia de NoteScreenState para acceder a métodos y propiedades
  NoteScreenState catColor = NoteScreenState();
  @override
  Widget build(BuildContext context) {
    //final themeMode = AdaptiveTheme.of(context).mode; // Obtener el modo del tema
    // Determina colores según el tema (claro u oscuro)
    Color botonColor = Theme.of(context).brightness == Brightness.light
        ? Color(0xFFFFFFFF)
        : Color(0xFF14181B);
    Color textColor = Theme.of(context).brightness == Brightness.light
        ? Color(0xFF57636C)
        : Color(0xFF95A1AC);
    Color chiocColor = Theme.of(context).brightness == Brightness.light
        ? Color(0xFFE0E3E7)
        : Color(0xFF262D34);
    Color bordeColor = Theme.of(context).brightness == Brightness.light
        ? Color(0xFFF1F4F8)
        : Color(0xFF1D2428);
    Color backgroudcolor = Theme.of(context).brightness == Brightness.light
        ? Color(0xFFF1F4F8)
        : Color(0xFF1D2428);

    return WillPopScope(
      onWillPop: () async {
        //Navigator.pushNamed(context, '/'); // Esto regresará a la pantalla LogIn
        _showImagePickerDialog();
        return true; // Si retornas false, impedirá la navegación hacia atrás.
      },
      child: Scaffold(
        backgroundColor:
            backgroudcolor, // Establece el color de fondo de la pantalla.
        body: Stack(
          // Un Stack permite superponer widgets en capas.
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20), // Margen de 20 en izquierda y derecha
                  child: Column(
                    children: [
                      //padding para el espacio
                      Padding(
                        padding: EdgeInsets.only(top: 35),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _showImagePickerDialog,
                              //child: Padding(
                              //padding: EdgeInsets.only(left: 20),
                              child: Card(
                                elevation: 0,
                                color: Colors.transparent,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blueGrey,
                                  radius: 30,
                                  backgroundImage: _imagePathFromDatabase != null
                                      ? FileImage(File(_imagePathFromDatabase!))
                                      : null,
                                ),
                              ),
                              //),
                            ),
                            Spacer(),
                            Stack(
                              children: [
                                //se valida si el texto ocupa mas espacio se coloca
                                //en dos lineas
                                MediaQuery.of(context).size.width < 320.05
                                    ? Text(
                                  'Gestory\nPassword', // Texto dividido en dos líneas para pantallas pequeñas
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Title Large',
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                                    : Container(
                                  alignment: Alignment.center,
                                      child: Text(
                                  'Gestory Password', // Texto en una sola línea para pantallas más grandes
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Title Large',
                                      fontWeight: FontWeight.w500,
                                  ),
                                ),
                                    ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              //margin: EdgeInsets.only(right: 22),
                              height: 42,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFFE0E3E7), // Color del borde
                                  width: 1.0, // Ancho del borde
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Stack(
                                children: [
                                  // Dos íconos de modo (claro y oscuro) con un interruptor para cambiar el tema.
                                  Positioned(
                                    left: 0,
                                    top: 8,
                                    child: Icon(
                                      Icons.wb_sunny_rounded,
                                      color: Color(0xFF57636C),
                                      size: 24.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0, // Alinea el icono de modo oscuro a la derecha
                                    top: 8,
                                    child: Icon(
                                      Icons.mode_night_rounded,
                                      color: Colors.white, // Cambia el color según el modo
                                      size: 24.0,
                                    ),
                                  ),
                                  // se utiliza Transform.scale para escalar el interruptor.
                                  Transform.scale(
                                    scale: 2.0,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      // El color de los elementos cambia según el modo.
                                      child: Switch(
                                        value: AdaptiveTheme.of(context).mode ==
                                            AdaptiveThemeMode.light,
                                        onChanged: (bool value) {
                                          if (value) {// si es verdadero se matiene el modo claro
                                            AdaptiveTheme.of(context).setLight();
                                          } else {// si es false se pone el modo nocturno
                                            AdaptiveTheme.of(context).setDark();
                                          }
                                        },
                                        activeColor: Colors
                                            .transparent, // Pulgar transparente en modo oscuro y claro
                                        activeTrackColor: Colors
                                            .transparent, // Riel transparente en modo oscuro y claro
                                        inactiveThumbColor: Colors
                                            .transparent, // Color del pulgar del interruptor cuando está desactivado
                                        inactiveTrackColor: Colors
                                            .transparent, // Color del riel cuando el interruptor está desactivado
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Una fila de ChoiceChips para seleccionar una categoría.
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            //SizedBox(width: 20),
                            for (int index = 0;
                                index < _categories.length;
                                index++)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(_categories[index].name,
                                    style: TextStyle(
                                      fontSize: 18, // Tamaño de fuente personalizado
                                    ),
                                  ),
                                  // Verifica si este ChoiceChip está seleccionado
                                  selected: _selectedChipIndex == index,
                                  backgroundColor: chiocColor,
                                  labelStyle: TextStyle(
                                    color: textColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: bordeColor, // Color del borde
                                      width: 1.0, // Ancho del borde
                                    ),
                                    // Radio del borde
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  //maneja la eleccion de categorias
                                  onSelected: (isSelected) {
                                    setState(() {
                                      // Selecciona o deselecciona este ChoiceChip
                                      _selectedChipIndex =
                                          isSelected ? index : -1;
                                      print(
                                          'Categoria Seleccionada: ${_categories[index].name}');
                                      print(
                                          '_selectedChipIndex: $_selectedChipIndex');
                                    });
                                  },
                                ),
                              ),
                            //SizedBox(width: 12),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Una división visual entre la selección de categoría y las notas.
                Divider(
                  color: Color(0xFF2874cf).withOpacity(0.2), // se le asigno un color
                  thickness: 2,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: getNotesForSelectedCategory().map((note) {
                        // Verifica si esta es la última nota
                        final isLastNote =
                            note == getNotesForSelectedCategory().last;
                        return Column(
                          children: [
                            SizedBox(height: 24),
                            GestureDetector(
                              onTap: () {
                                // Abre un diálogo con detalles de la contraseña
                                // cuando se toca una nota
                                _showPasswordDialog(context, note);
                              },
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 20, top: 10, right: 20),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color:
                                        catColor.getColorByIndex(note.categoryId),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            // Alinea el texto a la izquierda
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                // Texto de la nota, con parte oculta
                                                hideText("contenido"),
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.justify,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Agrega el espacio después de la última nota
                            if (isLastNote) SizedBox(height: 24),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              // Alinea el widget en la esquina inferior derecha
              alignment: Alignment.bottomRight,
              child: Container(
                height: 80,
                width: 100,
                decoration: BoxDecoration(
                  // Forma circular del contenedor
                  shape: BoxShape.circle,
                  // Color de fondo del botón
                  color: botonColor,
                  border: Border.all(
                    // Color del borde del botón
                    color: chiocColor,
                    width: 4.0, // Ancho del borde
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    print('Icono presionado');
                    Navigator.pushNamed(context, '/notes');
                  },
                  child: Icon(
                    // Ícono de "Agregar" representado por un signo más
                    Icons.add,
                    size: 48, // Tamaño del ícono
                    color: Color(0xFF2874cF), // Color del ícono
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}