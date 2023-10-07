import 'package:flutter/material.dart';
import 'package:app_2/src/inicio.dart';
import '../db/databaseCategory.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../db/notesdb.dart';
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
            home: NoteScreen(),// Define la página de inicio como MyHomePage
          );
        }
    );
  }
}
class NoteScreen extends StatefulWidget {
  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  List<Note> _notes = [];
  List<Notea> notes = []; // Lista para almacenar las notas desde la base de datos

  String _selectedCategory = ''; // Sin opción "Seleccionar"
  Color? _selectedColor = Colors.transparent; // Color como nullable
  List<String> _categories = [];
  List<Color> _categoryColors = [];
  bool _showAddButton = true; // Mostrar el botón "+" al inicio

  @override
  void initState() {
    super.initState();
    _loadCategories();
    final dbHelper = DatabaseHelper();
    dbHelper.printTableNames();
  }

  bool _categoriesLoaded = false; //se declara una variable de tipo booleano
//es un metodo que se utiliza para cargar las categorias desde una base de datos y actualiar el estado del widget
  void _loadCategories() async {
    if (!_categoriesLoaded) {
      //se utiliza para asegurarse de que las categorías se carguen solo una vez
      final dbHelper =
      DatabaseHelper(); //se crea una instancia de la clase DatabaseHelper
      final categories = await dbHelper
          .getCategories(); //llama al método getCategories() de la instancia de DatabaseHelper creada anteriormente

      if (categories.isEmpty) {
        //verifica si la lista de categories está vací
        final defaultCategories = ['Bancos', 'Correos', 'Redes Sociales'];
        int idCounter = 0; // Inicializa el contador de ID en 1
        //itera a través de la lista
        for (var category in defaultCategories) {
          // Asigna un color basado en el índice de categoría
          final colorIndex = defaultCategories.indexOf(
              category);
          final newCategoryColor = getColorByIndex(
              colorIndex); 
          //Se crea un nuevo objeto Category con dos atributos
          final newCategory =
          Category(id: idCounter, name: category, color: newCategoryColor!.value);
          await dbHelper.insertCategory(
              newCategory); //insertar este nuevo objeto Category en la base de datos local.
          idCounter++;
        }

        final updatedCategories = await dbHelper
            .getCategories(); //las categorías se almacenan en updatedCategories, y posteriormente se utiliza esta lista para actualizar el estado de la aplicación

        setState(() {
          _categories =
              updatedCategories.map((category) => category.name).toList();
          _categoryColors = updatedCategories
              .map((category) => Color(category.color))
              .toList();
          _categoriesLoaded = true;
        });
      } else {
        setState(() {
          _categories = categories.map((category) => category.name).toList();
          _categoryColors =
              categories.map((category) => Color(category.color)).toList();
          _categoriesLoaded = true;
        });
      }
    }
  }

//funcion para agregar nueva categoria
  void _addCategory(String category, Color color) async {
    final dbHelper = DatabaseHelper(); //Se crea una instancia de la clase
    final existingCategories = await dbHelper
        .getCategories();
    if (existingCategories
        .any((existingCategory) => existingCategory.name == category)) {
      print('Ya existe una categoría con el mismo nombre.');
    } else {
      final newCategory = Category(
          name: category,
          color: color
              .value);
      final result = await dbHelper.insertCategory(
          newCategory);
      if (result == -1) {
        print('Color duplicado. No se pudo insertar la categoría.');
      } else {
        setState(() {
          _categories.add(
              category); //Agrega el nombre de la nueva categoría (category) a la lista _categories.
          _categoryColors.add(
              color); //Agrega el color de la nueva categoría (color) a la lista _categoryColors.
          _selectedColor =
              color; //Actualiza la variable _selectedColor con el color de la nueva categoría.
          _selectedCategory =
              category; //Actualiza la variable _selectedCategory con el nombre de la nueva categoría.
          _showAddButton =
          false; // para ocultar el botón de agregar al agregar una categoría.
        });
      }
    }
  }
  //Esto define una función de tipo color
  Color? getColorByIndex(int index) {
    List<Color> availableColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.brown,
      Colors.yellow
    ];

    //Se le asigna un indice a cada color
    return index >= 0 && index < availableColors.length
        ? availableColors[index]
        : null; // Devuelve null si no hay colores
  }

//muestra un cuadro de diálogo en la interfaz de usuario para permitir al usuario agregar una nueva categoría
  void _showAddCategoryDialog() {
    TextEditingController _categoryController =
    TextEditingController(); //Se crea un controlador de texto
    String newCategory =
        ''; //Se declara una cadena vacía para almacenar el nombre de la categoria
    Color? newCategoryColor = getColorByIndex(_categories
        .length);

    //Se crea una estructura condicional
    if (newCategoryColor == null) {
      //si es nulo significa que no hay colores disponibles
      showDialog(
        //mensaje de dialogo para el usuario
        context:
        context, //se utiliza para obtener el contexto de la aplicación actual
        builder: (context) {
          //es un constructor de funciones anónimas
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
      //si no es nulo, se muestra el cuadro de dialogo para ingresar las categorias
      showDialog(
        context:
        context, //se utiliza para obtener el contexto de la aplicación actual
        //constructor de funciones anónimas
        builder: (context) {
          //Dentro de la función anónima, se devuelve un widget
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
                      'Nombre de la categoría'), //decoración al campo de entrada de texto
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

  void _addNotea() async {
    final title = _titleController.text;
    final content = _contentController.text;
    int categoryId; // Define categoryId como una variable de la clase

    if (title.isNotEmpty && content.isNotEmpty && _selectedCategory.isNotEmpty) {
      // Buscar el índice de la categoría seleccionada en la lista de categorías
      final categoryIndex = _categories.indexOf(_selectedCategory);


      if (categoryIndex != -1) {
        // Verificar que se encontró la categoría seleccionada en la lista
        categoryId = categoryIndex; // Usar el índice como categoryId
      } else {
        // Manejar el caso en el que la categoría no se encuentra en la lista
        print('Error: Categoría seleccionada no encontrada en la lista.');
        return; // Salir de la función si no se encuentra la categoría
      }

      final dbNota = DatabaseHelper.internal();
      final newNotea = Notea(
        title: title,
        content: content,
        categoryId: categoryId,

      );

      try {
        final noteId = await dbNota.insert(newNotea, categoryId);

        if (noteId != null && noteId > 0) {
          Fluttertoast.showToast(
            msg: 'Nota guardada con éxito',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // Espera a que se inserte la nueva nota y luego carga las notas desde la base de datos
          _loadNotesFromDatabase();

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
            _titleController.clear();
            _contentController.clear();
            _selectedCategory = '';
            _selectedColor = null;
            _showAddButton = true;
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Error al guardar la nota',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
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

  void _loadNotesFromDatabase() async {
    final allNotes = await DatabaseHelper.internal().getAllNotes();
    setState(() {
      notes = allNotes;
    });

    // Recorrer las notas y asignar el color de la categoría
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
  // método build de un widget, que se encarga de construir la interfaz de usuario del widget.
  Widget build(BuildContext context) {
    Color backgroudcolor = Theme.of(context).brightness == Brightness.light ? Color(0xFFF1F4F8) : Color(0xFF1D2428);

    return Scaffold(
      backgroundColor: backgroudcolor,
      //Este método construye un widget Scaffold, que es un esqueleto de la pantalla de la aplicación
      appBar: AppBar(
        backgroundColor: backgroudcolor,
        //Se configura la barra de navegación superior (AppBar) en el Scaffold
        //Esta propiedad se utiliza para colocar un widget en la parte izquierda de la AppBar. En este caso, se coloca un botón en la parte izquierda.
        leading: IconButton(
          //es un widget que representa un botón de icono.
          icon: Icon(
            //Dentro del IconButton, se define el icono que se mostrará
            Icons
                .other_houses_outlined, //es un icono de una casa con un contorno
            color: Colors.grey[800], //define le color del icono
            size: 38.0, //tamaño del icono
          ),
          //Esta propiedad especifica la función que se ejecutará cuando se presione el botón
          onPressed: () {
            Navigator.push(
              //realiza una navegación a otra pantalla
              context, //se utiliza para obtener el contexto de la aplicación actual
              //La navegación se realiza mediante MaterialPageRoute, que es una forma común de navegar entre pantallas
              MaterialPageRoute(builder: (context) => MyInicio()),
            );
          },
        ),
      ),
      //representa la estructura de la interfaz de usuario (UI) de una pantalla en la aplicación
      body: Padding(
        //El contenido principal de la pantalla se encuentra en el cuerpo (body) de la pantalla.
        padding: EdgeInsets.all(
            16.0), //se agrega un relleno de 16.0 píxeles en todos los lados del contenido.
        child: SingleChildScrollView(
          child: Column(
            // se utiliza Column para organizar el contenido verticalmente.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              Row(
                //Se utiliza para organizar elementos en una fila horizontal
                children: [
                  Text(
                    //muestra el contenido de la interfaz
                    'Crea nueva nota', //texto que se muestra en pantalla
                    style: TextStyle(
                      //proporciona el estilo del texto
                      fontSize: 24, //tamaño de la fuente
                      fontFamily: 'Headline Medium',
                    ),
                  ),
                  SizedBox(
                      width: 8.0), //se le agrega un espacio vacio con un ancho
                  Row(
                    //Se utiliza para organizar elementos en una fila horizontal
                    children: [
                      Container(
                        //se utiliza para mostrar un círculo de color (_selectedColor) junto con el nombre de la categoría seleccionada (_selectedCategory)
                        width: 24, //se le coloca un ancho al container
                        height: 24, //se le coloca un alto al container
                        decoration: BoxDecoration(
                          //se le coloca un border redondeado
                          shape: BoxShape
                              .circle, //configura el container como un circulo
                          color: _selectedColor, //contiene un valor de color
                        ),
                      ),
                      SizedBox(
                          width:
                          8.0), //se le agrega un espacio vacio con un ancho
                      Text(
                          _selectedCategory), //Esta variable puede cambiar dinámicamente a medida que el usuario selecciona diferentes categorías.
                    ],
                  ),
                  SizedBox(
                      width: 8.0), //se le agrega un espacio vacio con un ancho
                  _showAddButton
                  //Este es el widget del botón desplegable. Cuando se toca, muestra una lista de elementos que el usuario puede seleccionar.
                      ? PopupMenuButton<Map<String, dynamic>>(
                    //se crea un icono
                    icon: Icon(
                      Icons.add_circle,
                      color: Colors.blue, //se le asigna el color
                      size: 40.0, //tamaño del icono
                    ),
                    //cuando el usuario seleccion un elemento del boton despegable, se activa la funcion onSelected
                    //onSelected recibe un argumento selection, que es un mapa (Map<String, dynamic>) que contiene información sobre la selección del usuario.
                    // En este mapa, "category" es la clave que contiene el nombre de la categoría seleccionada, y "color" es la clave que contiene el color asociado a la categoría (puede ser nulo si es una nueva categoría).
                    onSelected: (Map<String, dynamic> selection) {
                      //Si "category" es igual a "Add", se llama a _showAddCategoryDialog()
                      if (selection['category'] == 'Add') {
                        _showAddCategoryDialog();
                      } else {
                        //Si "category" no es igual a "Add", significa que el usuario seleccionó una categoría existente. En este caso, se actualizan las variables _selectedColor y _selectedCategory con los valores del mapa selection
                        setState(() {
                          _selectedColor = selection['color'];
                          _selectedCategory = selection['category'];
                          _showAddButton =
                          false; //oculta el botón desplegable después de la selección.
                        });
                      }
                    },
                    //es una función que se llama cuando se construye el menú desplegable.
                    itemBuilder: (BuildContext context) {
                      //Se crea una lista items que contendrá los elementos del menú desplegable. Esta lista se inicializa como una lista vacía.
                      List<PopupMenuEntry<Map<String, dynamic>>> items =
                      _categories.map((category) {
                        //para iterar a través de la lista de categorías _categories
                        int index = _categories.indexOf(
                            category); //busca el índice de la categoría actual (category) dentro de la lista _categories
                        Color? color = getColorByIndex(
                            index); //Una vez que se obtiene el índice de la categoría actual, se llama a la función _getColorByIndex(index) para obtener el color asociado a esa categoría.
                        //Esta línea crea un elemento de menú emergente
                        return PopupMenuItem<Map<String, dynamic>>(
                          //Se utiliza un mapa con dos claves: 'color' y 'category', y se les asigna los valores color (el color asociado a la categoría) y category (el nombre de la categoría)
                          value: {
                            'color': color,
                            'category': category,
                          },
                          child: CategoryMenuItem(
                            //mostrará la categoría con su color específico
                            color: color, //
                            category: category,
                          ),
                        );
                      }).toList(); //se utiliza para convertir un iterable (como una lista o un generador)
                      items.add(
                        // operación que se utiliza para agregar un elemento a una lista
                        PopupMenuItem<Map<String, dynamic>>(
                          //se utiliza para crear un elemento de menú que contiene información sobre una categoría.
                          value: {
                            //define el valor asociado con este elemento de menú
                            'color': getColorByIndex(_categories
                                .length), //es el color obtenido por el método _getColorByIndex basado en la cantidad actual de categorías
                            'category':
                            'Add', //Sirve para identificar que se seleccionó la opción de agregar una nueva categoría en el menú.
                          },
                          child: Row(
                            //se crea una fila
                            children: [
                              Icon(
                                //se agrega un icono y se le asigna un color
                                Icons.add_circle,
                                color: Colors.grey[800],
                              ),
                              SizedBox(
                                  width: 8.0), //crea un espacio horzontal
                              Text(
                                  'Agregar nueva categoría'), //se establece el texto
                            ],
                          ),
                        ),
                      );
                      return items; // se utiliza para finalizar la construcción de los elementos de menú y devolver la lista completa de elementos de menú que se mostrarán en el menú emergente.
                    },
                  )
                      : SizedBox(), //se agrega un espacion vacio sin contenido
                ],
              ),
              SizedBox(height: 16.0), //crea un espacio vertical
              TextField(
                //se agrega un campo de texto, con un texto, con un estilo
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'título', //titulo de la etiqueta
                  labelStyle: TextStyle(
                    fontFamily: 'Headline Small',
                    fontWeight: FontWeight
                        .bold, // Cambia a fontWeight para hacerlo negrita
                    fontSize: 24.0, // Cambia a fontFamily en lugar de fontWeight
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                //se agrega un campo de texto, con un texto, con un estilo
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: 'contenido..',
                  labelStyle: TextStyle(
                    fontFamily: 'Headline Small',
                    fontSize: 16.0, // Cambia a fontFamily en lugar de fontWeight
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addNotea,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12), // Radio de 12 en los bordes
                  ),
                ),
                child: Container(
                  height: 54,
                  // Ancho personalizado
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .receipt_long, // Agregar el icono "Receipt Long" aquí
                        size: 32.0, // Tamaño del icono
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

  const CategoryMenuItem({
    Key?
    key, // se utiliza para proporcionar una clave única a la instancia de CategoryMenuItem
    required this.color, //se utiliza para especificar el color que se asociará con el elemento de menú de categoría.
    required this.category, //se utiliza para especificar el nombre de la categoría que se mostrará en el elemento de menú
  }) : super(key: key);

  //se encarga de construir y devolver la interfaz de usuario para un elemento de menú de categoría.
  @override //
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          //Se crea un contenedor rectangular que contiene el círculo de color que representa la categoría.
          width: 24, //se agrega un ancho de 24 al container
          height: 24, //se agrega un alto de 24 al container
          decoration: BoxDecoration(
            //aqui se define que va a ser circular y se muestra el color de cada categoria
            shape: BoxShape.circle,
            color: color, // Usar un color predeterminado si es nulo
          ),
        ),
        SizedBox(width: 8.0), //se agrega un espacion horizontal
        Text(category), //se muestra el nombre de la categoria
      ],
    );
  }
}