import 'dart:convert';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/databaseCategory.dart';
import '../db/notesdb.dart';
import 'note.dart';

// Definición de la clase MyInicio, que es un StatelessWidget
class MyInicio extends StatelessWidget {
  // Constructor de MyInicio que toma un parámetro opcional de tipo 'key'
  const MyInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final initialMode = brightness == Brightness.dark ? AdaptiveThemeMode.dark : AdaptiveThemeMode.light;
    // Devuelve un AdaptiveTheme, que permite cambiar entre temas oscuros y claros
    return AdaptiveTheme(
      // Tema oscuro
        dark: ThemeData.dark(),
        // Tema claro
        light: ThemeData.light(),
        // Modo de tema inicial
        initial: initialMode,
        // Builder que configura el tema en función del AdaptiveTheme
        builder: (theme, darkTheme){
          // Devuelve un MaterialApp que utiliza el tema proporcionado
          return MaterialApp(
            title: 'Gestory Password',
            theme: theme,
            darkTheme: darkTheme,
            home: MyHomePage(),// Define la página de inicio como MyHomePage
          );
        }
    );
  }
}
//widget que puede cambiar de estado a lo largo del tiempo
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File? _image; // Variable para almacenar una imagen (puede ser nula)
  int _selectedChipIndex = -1; // Índice de la categoría seleccionada (inicializado en -1)
  List<Category> _categories = []; // Lista para almacenar categorías
  List<Notea> _notes = [];
  bool _imageLoaded = false;

  String? _imagePathFromDatabase; // Variable de tipo String para almacenar una ruta de imagen (puede ser nula)

  // Método que se llama al inicializar el estado
  @override
  void initState() {
    super.initState(); // Llama al método initState de la clase base
    //retrieveAndPrintImage(); // Llama al método retrieveAndPrintImage
    if(!_imageLoaded){
      retrieveAndPrintImage();
    }
    _loadCategories(); // Llama al método _loadCategories al iniciar la pantalla
    _loadNotes();
  }
  //carga las categorias de la base de datos
  void _loadCategories() async {
    final dbHelper = DatabaseHelper(); // Instancia de DatabaseHelper para interactuar con la base de datos
    final categories = await dbHelper.getCategories(); //evuelve una lista de categorías

    setState(() {
      _categories = categories;// Actualiza la lista de categorías en el estado con las categorías cargadas desde la base de datos
    });
  }

  void _loadNotes() async {
    try {
      final dbHelper = DatabaseHelper();
      final notes = await dbHelper.getAllNotes();
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      print('Error al cargar notas: $e');
    }
  }
  // Recupera y muestra una imagen desde la base de datos
  Future<void> retrieveAndPrintImage() async {
    final db = await DatabaseHelper().db;// Obtiene una instancia de la base de datos
    final List<Map<String, dynamic>> imageList = await db!.query('images');// Consulta la tabla 'images' en la base de datos

    if (imageList.isNotEmpty) {
      final imagePath = imageList.first['image_path'] as String;// Obtiene la ruta de la imagen desde la lista

      // Cargar la imagen desde la ruta de la base de datos
      final imageFile = File(imagePath);

      if (imageFile.existsSync()) {
        // Leer los bytes de la imagen y mostrarlos en la consola como una cadena
        final imageBytes = await imageFile.readAsBytes();
        final imageBase64 = base64Encode(imageBytes);

        print('Imagen guardada en la base de datos a Base64: $imageBase64');

        // Asigna la ruta de la imagen directamente a _imagePathFromDatabase
        // Activa un cambio en la interfaz de usuario para reflejar la nueva imagen
        setState(() {
          _imagePathFromDatabase = imagePath;
          _imageLoaded = true;
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
    final picker = ImagePicker();// Instancia de ImagePicker para capturar imágenes
    final pickedFile = await picker.pickImage(source: ImageSource.camera);// Captura una imagen desde la cámara
    if (pickedFile != null) {
      // Si se capturó una imagen con éxito
      setState(() {
        _image = File(pickedFile.path); // Asigna la imagen capturada a la variable _image
        _imagePathFromDatabase = _image?.path;
      });

      // Obtén la instancia de DatabaseHelper y luego inserta la imagen
      final databaseHelper = DatabaseHelper();
      final imagePath = _image?.path; // Instancia de DatabaseHelper para interactuar con la base de datos
      //await databaseHelper.printImagesInDatabase();

      try {
        await databaseHelper.insertImage(imagePath!); // Inserta la ruta de la imagen en la base de datos
        print("Imagen guardada con exito");
      } catch (e) {
        print('Error al insertar la imagen en la base de datos: $e');
      }
    }
  }
  // Selecciona una imagen desde la galería y la guarda en la base de datos
  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker(); // Instancia de ImagePicker para seleccionar imágenes de la galería
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);// Selecciona una imagen desde la galería
    if (pickedFile != null) {
      // Si se seleccionó una imagen con éxito
      setState(() {
        _image = File(pickedFile.path); // Asigna la imagen seleccionada a la variable _image
        _imagePathFromDatabase = _image?.path;
      });

      // Obtén la instancia de DatabaseHelper y luego inserta la imagen
      final databaseHelper = DatabaseHelper(); // Instancia de DatabaseHelper para interactuar con la base de datos
      final imagePath = _image?.path; // Obtiene la ruta de la imagen seleccionada

      try {
        await databaseHelper.insertImage(imagePath!); // Inserta la ruta de la imagen en la base de datos
      } catch (e) {
        print('Error al insertar la imagen en la base de datos: $e');
      }
    }
  }

  // Muestra un diálogo para seleccionar entre tomar una foto o seleccionar desde la galería
  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar imagen'), // Título del diálogo
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Tomar foto'), // Opción para tomar una foto
                  onTap: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    _getImageFromCamera(); // Llama al método para tomar una foto
                  },
                ),
                SizedBox(height: 20), // Espacio en blanco
                GestureDetector(
                  child: Text('Seleccionar desde galería'), // Opción para seleccionar desde la galería
                  onTap: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    _getImageFromGallery(); // Llama al método para seleccionar desde la galería
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  List<Notea> getNotesForSelectedCategory() {
    if (_selectedChipIndex == -1) {
      // Si no se ha seleccionado ninguna categoría, devuelve todas las notas
      return _notes;
    } else {
      // Filtra las notas por la categoría seleccionada
      final selectedCategory = _categories[_selectedChipIndex];
      return _notes.where((note) => note.categoryId == selectedCategory.id).toList();
    }
  }

  //funcion para que el contenido se muestre en asteriscos
  String hideText(String text){
    return '*' * text.length;
  }

  NoteScreenState catColor = NoteScreenState();
  @override
  Widget build(BuildContext context) {
    Color botonColor = Theme.of(context).brightness == Brightness.light ? Color(0xFFFFFFFF) : Color(0xFF14181B);
    Color textColor = Theme.of(context).brightness == Brightness.light ? Color(0xFF57636C) : Color(0xFF95A1AC);
    Color chiocColor = Theme.of(context).brightness == Brightness.light ? Color(0xFFE0E3E7) : Color(0xFF262D34);
    Color bordeColor = Theme.of(context).brightness == Brightness.light ? Color(0xFFF1F4F8) : Color(0xFF1D2428);
    Color backgroudcolor = Theme.of(context).brightness == Brightness.light ? Color(0xFFF1F4F8) : Color(0xFF1D2428);


    return Scaffold(
      backgroundColor: backgroudcolor,
      body: Stack(
        children: [
          Column(
            children: [
              Column(
                children: [
                  //Container(
                  //margin: EdgeInsets.only(left: 20,top: 40, right: 20),
                  //child:
                  Padding(
                    padding: EdgeInsets.only(left: 20,top: 40, right: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Padding(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 2),
                            child: Card(
                              elevation: 0,
                              color: Color(0xFFFFFF),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: _imagePathFromDatabase != null
                                    ? FileImage(File(_imagePathFromDatabase!))
                                    : AssetImage('assets/imagen.jpg') as ImageProvider<Object>?,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Stack(
                          children: [
                            Text(
                              'Gestory Password',
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily:
                                'Title Large',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),//SizedBox(width: double.maxFinite),
                        Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFE0E3E7), // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          padding: EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              const Positioned(
                                left: 6, // Alinea el icono de modo claro a la izquierda
                                top: 8,
                                child: Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Color(0xFF57636C), // Cambia el color según el modo
                                  size: 24.0,
                                ),
                              ),
                              const Positioned(
                                right: 0, // Alinea el icono de modo oscuro a la derecha
                                top: 8,
                                child: Icon(
                                  Icons.mode_night_rounded,
                                  color: Colors.white, // Cambia el color según el modo
                                  size: 24.0,
                                ),
                              ),
                              Transform.scale(
                                scale: 2.0,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Switch(
                                    value: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
                                    onChanged: (bool value) {
                                      if (value) {
                                        AdaptiveTheme.of(context).setLight();
                                      } else {
                                        AdaptiveTheme.of(context).setDark();
                                      }
                                    },
                                    activeColor: Colors.transparent, // Pulgar transparente en modo oscuro y claro
                                    activeTrackColor: Colors.transparent, // Riel transparente en modo oscuro y claro
                                    inactiveThumbColor: Colors.transparent, // Color del pulgar del interruptor cuando está desactivado
                                    inactiveTrackColor: Colors.transparent, // Color del riel cuando el interruptor está desactivado
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 20),

                        for (int index = 0; index < _categories.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(_categories[index].name,
                                style: TextStyle(
                                  fontSize: 18, // Tamaño de fuente personalizado
                                ),
                              ),
                              selected: _selectedChipIndex == index, // Verifica si este ChoiceChip está seleccionado
                              backgroundColor: chiocColor,
                              labelStyle: TextStyle(
                                color: textColor,
                              ),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: bordeColor, // Color del borde
                                  width: 1.0, // Ancho del borde
                                ),
                                borderRadius: BorderRadius.circular(16.0), // Radio del borde
                              ),
                              onSelected: (isSelected) {
                                setState(() {
                                  _selectedChipIndex = isSelected ? index : -1;// Selecciona o deselecciona este ChoiceChip
                                  print('Categoria Seleccionada: ${_categories[index].name}');
                                  print('_selectedChipIndex: $_selectedChipIndex');
                                });
                              },
                            ),
                          ),
                        SizedBox(width: 12),
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                color: Color(0xFF2874cf).withOpacity(0.2), // se le asigno un color
                thickness: 2,
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                    getNotesForSelectedCategory().map((note) {
                      final isLastNote = note == getNotesForSelectedCategory().last; // Verifica si esta es la última nota
                      return  Column(
                        children: [
                          SizedBox(height: 24),
                          GestureDetector(
                            onTap: (){
                              print('Aqui debe abrir el archivo');
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, top: 10, right: 20),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: catColor.getColorByIndex(note.categoryId),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda
                                          children: [
                                            Text(
                                              note.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 19,
                                                fontFamily: 'Headline Small',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              hideText(note.content),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Body Small',
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
                          if (isLastNote) SizedBox(height: 24), // Agrega el espacio después de la última nota
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 80,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: botonColor,
                border: Border.all(
                  color: chiocColor, // Color del borde
                  width: 4.0, // Ancho del borde
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  print('Icono presionado');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyNote()),
                  );
                },
                child: const Icon(
                  Icons.add,
                  size: 48,
                  color: Color(0xFF2874cF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}