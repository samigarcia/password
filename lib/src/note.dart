import 'package:flutter/material.dart';
import 'package:app_2/src/inicio.dart';
import '../db/databaseCategory.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Entity/notas.dart';
import '../Entity/categorias.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
class Note {
  String title;
  String content;
  Color color;
  String category;

  Note(this.title, this.content, this.color, this.category);
}

class MyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final initialMode = brightness ==
        Brightness.dark ? AdaptiveThemeMode.dark : AdaptiveThemeMode.light;
    //cambia entre temas oscuros y claros
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
            home: NoteScreen(),// Define la página de inicio como MyHomePage
          );
        }
    );
  }
}
// Declaración de la clase NoteScreen que extiende StatefulWidget.
class NoteScreen extends StatefulWidget {
  @override
  NoteScreenState createState() => NoteScreenState();
}
// Declaración de la clase NoteScreenState que extiende State<NoteScreen>.
class NoteScreenState extends State<NoteScreen> {
  // Declaración de controladores de texto para el título y el contenido de la nota.
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  // Declaración de una lista para almacenar las notas.
  List<Note> _notes = [];
  // Lista para almacenar las notas desde la base de datos
  List<Notea> notes = [];
  // Declaración de una cadena para almacenar la categoría seleccionada.
  String _selectedCategory = '';
  // Declaración de un objeto Color nullable para almacenar el color seleccionado.
  Color? _selectedColor = Colors.transparent;
  // Declaración de listas para almacenar categorías y sus colores correspondientes.
  List<String> _categories = [];
  List<Color> _categoryColors = [];
  // Declaración de una bandera para mostrar o no el botón "+" al inicio.
  bool _showAddButton = true; // Mostrar el botón "+" al inicio

  @override
  void initState() {
    super.initState();
    // Se ejecuta al inicializar la pantalla.
    // Cargar categorías disponibles.
    _loadCategories();
  }
// Declaración de una variable booleana para rastrear si las categorías se han cargado.
  bool _categoriesLoaded = false;
  // Función asincrónica para cargar categorías desde la base de datos.
  void _loadCategories() async {
    if (!_categoriesLoaded) {// Comprobar si las categorías ya se han cargado.
      // Crear una instancia de DatabaseHelper para interactuar con la base de datos.
      final dbHelper = DatabaseHelper();
      // Obtener las categorías desde la base de datos.
      final categories = await dbHelper.getCategories();
      if (categories.isEmpty) {// Si no se encontraron categorías en la base de datos:
        // Categorías por defecto.
        final defaultCategories = ['Bancos', 'Correos', 'Redes Sociales'];
        int idCounter = 0;
        for (var category in defaultCategories) {
          final colorIndex = defaultCategories.indexOf(category);
          // Obtener el color para la categoría en función de su índice.
          final newCategoryColor = getColorByIndex(colorIndex);
          // Crear un objeto Category con un ID único, nombre y color.
          final newCategory =
          Category(id: idCounter, name: category, color: newCategoryColor!.value);
          // Insertar la nueva categoría en la base de datos.
          await dbHelper.insertCategory(newCategory);
          idCounter++;
        }
        // Actualizar la lista de categorías desde la base de datos.
        final updatedCategories = await dbHelper
            .getCategories();
        // Actualizar el estado de la pantalla.
        setState(() {
          _categories =
              updatedCategories.map((category) => category.name).toList();
          _categoryColors = updatedCategories
              .map((category) => Color(category.color))
              .toList();
          _categoriesLoaded = true;
        });
      } else {// Si se encontraron categorías en la base de datos:
        // Actualizar la lista de categorías y colores desde la base de datos.
        setState(() {
          _categories = categories.map((category) => category.name).toList();
          _categoryColors =
              categories.map((category) => Color(category.color)).toList();
          _categoriesLoaded = true;
        });
      }
    }
  }
  // Función para agregar una nueva categoría a la base de datos.
  void _addCategory(String category, Color color) async {
    // Crear una instancia de DatabaseHelper para interactuar con la base de datos.
    final dbHelper = DatabaseHelper();
    // Obtener las categorías existentes desde la base de datos.
    final existingCategories = await dbHelper
        .getCategories();
    if (existingCategories
        .any((existingCategory) => existingCategory.name == category)) {
      // Comprobar si ya existe una categoría con el mismo nombre en la base de datos.
      print('Ya existe una categoría con el mismo nombre.');
    } else {
      // Crear un nuevo objeto Category con el nombre y color especificados.
      final newCategory = Category(
          name: category,
          color: color
              .value);
      // Insertar la nueva categoría en la base de datos y obtener el resultado.
      final result = await dbHelper.insertCategory(
          newCategory);
      if (result == -1) {
        // Comprobar si hubo un error debido a un color duplicado en la base de datos.
        print('Color duplicado. No se pudo insertar la categoría.');
      } else {
        // Actualizar las listas de categorías y colores en el estado de la pantalla.
        setState(() {
          _categories.add(
              category);
          _categoryColors.add(
              color);
          _selectedColor =
              color;
          _selectedCategory =
              category;
          _showAddButton =
          true;
        });
      }
    }
  }
  // Función para obtener un color de la lista de colores disponibles por índice.
  Color? getColorByIndex(int index) {
    List<Color> availableColors = [
      Color(0xFFFFB6C1),
      Color(0xFFADD8E6),
      Color(0xFFFFFF66),
      Color(0xFF98FB98),
      Color(0xFFD8BFD8),
      Color(0xFFFFCC99),
      Color(0xFFAFEEEE),
      Color(0xFFC0C0C0),
      Color(0xFFF5F5DC),
      Color(0xFFE6E6FA),
      Color(0xFFB2FFFF),
      Color(0xFFFFFACD),
      Color(0xFFFF7F50),
      Color(0xFF98FF98),
      Color(0xFFFFE5B4),
      Color(0xFF87CEEB),
      Color(0xFFE6E6FA),
      Color(0xFFADD8E6),
      Color(0xFFFFFF99),
      Color(0xFFFFB347),
    ];
    return index >= 0 && index < availableColors.length
        ? availableColors[index]
        : null;
  }
  // Función para mostrar un cuadro de diálogo para agregar una nueva categoría.
  void _showAddCategoryDialog() {
    TextEditingController _categoryController =
    TextEditingController();
    String newCategory = '';
    Color? newCategoryColor = getColorByIndex(_categories
        .length);

    //Se crea una estructura condicional
    if (newCategoryColor == null) {
      // Si no hay colores disponibles para nuevas categorías, mostrar un mensaje.
      showDialog(
        context:
        context, //se utiliza para obtener el contexto de la aplicación actual
        builder: (context) {
          return AlertDialog(
            title: Text(
                'No se pueden agregar más categorías'),
            content: Text(
                'No hay colores disponibles para nuevas categorías.'),
            //es una lista de acciones que se pueden realizar en el cuadro de diálogo.
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Aceptar'), //Texto que se encuentra en el boton
              ),
            ],
          );
        },
      );
    } else {
      // Mostrar el cuadro de diálogo para agregar una nueva categoría.
      showDialog(
        context:
        context, //se utiliza para obtener el contexto de la aplicación actual
        builder: (context) {
          return AlertDialog(
            //representa el cuadro de diálogo
            title: Text(
                'Agregar nueva categoría'), //se crea un titulo del cuadro de diálogo como un widget
            //establece el contenido principal del cuadro de diálogo como una columna (Column) de widgets
            content: Column(
              //crea un widget Column
              mainAxisSize: MainAxisSize
                  .min,
              // lista de widgets hijos
              children: [
                //campo de entrada de texto
                TextField(
                  controller:
                  _categoryController, //se especifica el controlador de texto
                  decoration: InputDecoration(
                      labelText:
                      'Nombre de la categoría'),
                  onChanged: (value) {
                    newCategory = value;
                  },
                ),
              ],
            ),
            actions: [
              //botón de texto con el texto "Cancelar"
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'), //Texto que se encuentra en el boton
              ),
              //botón elevado con el texto "Agregar"
              ElevatedButton(
                onPressed: () {
                  if (newCategory.isNotEmpty) {
                    // Verificar si la categoría ya existe
                    if (_categories.contains(newCategory)) {
                      // Si la categoría ya existe, mostrar un mensaje.
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('La categoría ya existe.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Aceptar'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Agregar la nueva categoría utilizando la función
                      // _addCategory y cerrar el diálogo.
                      _addCategory(newCategory, newCategoryColor);
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Agregar'),
              ),
            ],
          );
        },
      );
    }
  }
  // Función para agregar una nueva nota a la base de datos.
  void _addNotea() async {
    final title = _titleController.text;
    final content = _contentController.text;
    int categoryId; // Define categoryId como una variable de la clase

    if (title.isNotEmpty && content.isNotEmpty && _selectedCategory.isNotEmpty) {
      // Buscar el índice de la categoría seleccionada en la lista de categorías
      final categoryIndex = _categories.indexOf(_selectedCategory);


      if (categoryIndex != null) {
        // Verificar que se encontró la categoría seleccionada en la lista
        categoryId = categoryIndex; // Usar el índice como categoryId
      } else {
        // Manejar el caso en el que la categoría no se encuentra en la lista
        print('Error: Categoría seleccionada no encontrada en la lista.');
        return; // Salir de la función si no se encuentra la categoría
      }
      // Crear una instancia de DatabaseHelper para interactuar con la base de datos.
      final dbNota = DatabaseHelper.internal();
      // Crear un nuevo objeto Notea con el título, contenido, categoryId e iv
      // (posiblemente una clave de encriptación).
      final newNotea = Notea(
        title: title,
        content: content,
        categoryId: categoryId, iv: '',
      );

      try {
        // Insertar la nueva nota en la base de datos y obtener el ID de la nota.
        final noteId = await dbNota.insert(newNotea, categoryId);
        if (noteId != null && noteId > 0) {
          // Mostrar un mensaje de éxito y cargar las notas desde la base de datos.
          Fluttertoast.showToast(
            msg: 'Nota guardada con éxito',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // Espera a que se inserte la nueva nota y luego carga las notas desde la base de datos
          _loadNotesFromDatabase();
          // Actualizar el estado de la pantalla.
          setState(() {
            // Aquí es donde se convierte el objeto Notea en Note
            _notes.add(
              Note(
                title,
                content,
                _selectedColor!,
                _selectedCategory,
              ),
            );
            // Limpiar los controladores y restablecer valores seleccionados.
            _titleController.clear();
            _contentController.clear();
            _selectedCategory = '';
            _selectedColor = null;
            _showAddButton = true;
          });
        } else {
          // Mostrar un mensaje de error si no se pudo guardar la nota.
          Fluttertoast.showToast(
            msg: 'Error al guardar la nota',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        // Manejar errores al insertar la nota en la base de datos.
        print('Error al insertar nota en la base de datos: $e');
        Fluttertoast.showToast(
          msg: 'Error al guardar la nota',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }
  // Función para cargar las notas desde la base de datos y asignar colores de categoría.
  void _loadNotesFromDatabase() async {
    // Obtener todas las notas de la base de datos.
    final allNotes = await DatabaseHelper.internal().getAllNotes();
    // Actualizar el estado de la pantalla con las notas cargadas.
    setState(() {
      notes = allNotes;
    });

    // Recorrer las notas y asignar el color de la categoría.
    for (final note in notes) {
      print('ID: ${note.id}, Título: ${note.title}, Contenido: ${note.content}, Category: ${note.categoryId}');
      final categoryIndex = note.categoryId; // Obtener el índice de la categoría
      final categoryColor = _categoryColors[categoryIndex]; // Obtener el color de la categoría
      final noteToAdd = Note(
        note.title,
        note.content,
        categoryColor, // Asignar el color de la categoría a la nota
        _categories[categoryIndex], // Obtener el nombre de la categoría
      );
      _notes.add(noteToAdd); // Agregar la nota a la lista _notes
    }
  }
  @override
  //se encarga de construir la interfaz de usuario del widget.
  Widget build(BuildContext context) {
    // Define el color de fondo de la aplicación en función del tema
    // actual (claro u oscuro).
    Color backgroudcolor = Theme.of(context).brightness ==
        Brightness.light ? Color(0xFFF1F4F8) : Color(0xFF1D2428);
    // Devuelve una estructura de widget Scaffold que representa la
    // pantalla principal de la aplicación.
    return Scaffold(
      backgroundColor: backgroudcolor,
      appBar: AppBar(
        backgroundColor: backgroudcolor,
        leading: IconButton(
          icon: Icon(
            Icons.other_houses_outlined,
            color: Colors.grey[800],
            size: 38.0,
          ),
          onPressed: () {
            // Navega a la pantalla de inicio cuando se presiona el ícono de inicio.
            Navigator.push(
              context, //obtiene el contexto de la aplicación actual
              MaterialPageRoute(builder: (context) => MyInicio()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(
            16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              // Encabezado que muestra el título y la categoría seleccionada.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Crea nueva nota',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Headline Medium',
                      ),
                    ),
                    SizedBox(
                        width: 8.0),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape
                                .circle,
                            color: _selectedColor,
                          ),
                        ),
                        SizedBox(
                            width:
                            8.0),
                        Text(
                            _selectedCategory), // La categoría se actualiza dinámicamente.
                      ],
                    ),
                    SizedBox(
                        width: 8.0),
                    // Botón desplegable para seleccionar una categoría o agregar una nueva.
                    _showAddButton ? PopupMenuButton<Map<String, dynamic>>(
                      //se crea un icono
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.blue, //se le asigna el color
                        size: 40.0, //tamaño del icono
                      ),
                      onSelected: (Map<String, dynamic> selection) {
                        if (selection['category'] == 'Add') {
                          _showAddCategoryDialog();
                        } else {
                          setState(() {
                            _selectedColor = selection['color'];
                            _selectedCategory = selection['category'];
                            _showAddButton =
                            true;
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry<Map<String, dynamic>>> items =
                        _categories.map((category) {
                          int index = _categories.indexOf(
                              category);
                          Color? color = getColorByIndex(
                              index);
                          return PopupMenuItem<Map<String, dynamic>>(
                            value: {
                              'color': color,
                              'category': category,
                            },
                            child: CategoryMenuItem(
                              color: color, //
                              category: category,
                            ),
                          );
                        }).toList();
                        // Agregar opción para agregar una nueva categoría.
                        items.add(
                          PopupMenuItem<Map<String, dynamic>>(
                            value: {
                              'color': getColorByIndex(_categories
                                  .length),
                              'category':
                              'Add',
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: Colors.grey[800],
                                ),
                                SizedBox(
                                    width: 8.0), //crea un espacio horizontal
                                Text(
                                    'Agregar nueva categoría'), //se establece el texto
                              ],
                            ),
                          ),
                        );
                        return items;
                      },
                    )
                        : SizedBox(), //se agrega un espacion vacio sin contenido
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              // Campos de entrada para el título y el contenido de la nota.
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'título', //titulo de la etiqueta
                  labelStyle: TextStyle(
                    fontFamily: 'Headline Small',
                    fontWeight: FontWeight
                        .bold,
                    fontSize: 24.0,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: 'contenido..',
                  labelStyle: TextStyle(
                    fontFamily: 'Headline Small',
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // Botón para crear una nueva nota.
              ElevatedButton(
                onPressed: _addNotea,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                child: Container(
                  height: 54,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .receipt_long,
                        size: 32.0,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'crear nota',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//esta clase se utiliza para mostrar un elemento de menú de categoría
class CategoryMenuItem extends StatelessWidget {
  final Color?
  color; //esta variable puede contener un valor de tipo Color o puede ser nulo (null)
  final String
  category; // Este campo es de tipo String y es obligatorio (requerido)

  // Constructor de la clase CategoryMenuItem.
  const CategoryMenuItem({
    Key?
    key, // se utiliza para proporcionar una clave única a la instancia de CategoryMenuItem
    required this.color, //se utiliza para especificar el color que se asociará con el elemento de menú de categoría.
    required this.category, //se utiliza para especificar el nombre de la categoría que se mostrará en el elemento de menú
  }) : super(key: key);

  // Esta función se encarga de construir y devolver la interfaz de usuario para un elemento de menú de categoría.
  @override //
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            //Se crea un contenedor rectangular que contiene el círculo de color que representa la categoría.
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: 8.0),
          Text(category), //se muestra el nombre de la categoria
        ],
      ),
    );
  }
}