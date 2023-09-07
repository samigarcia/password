import 'package:flutter/material.dart';
import 'package:app_2/src/inicio.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoteScreen(),
    );
  }
}

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String _selectedCategory = ''; // Sin opción "Seleccionar"
  Color _selectedColor = Colors.white;
  List<Note> _notes = [];
  List<String> _categories = ['Bancos', 'Correos', 'Redes sociales'];
  List<Color> _categoryColors = [Colors.red, Colors.blue, Colors.green];
  bool _showAddButton = true; // Mostrar el botón "+" al inicio

  void _addCategory(String category, Color color) {
    setState(() {
      _categories.add(category);
      _categoryColors.add(color);
      _selectedColor = color;
      _selectedCategory = category;
      _showAddButton =
          false; // Ocultar el botón "+" cuando se selecciona una categoría
    });
  }

  void _updateCategoryColors() {
    _categoryColors = _categories.map((category) {
      int index = _categories.indexOf(category);
      if (index < _categoryColors.length) {
        return _categoryColors[index];
      } else {
        return Colors.grey;
      }
    }).toList();
  }

  Color _getColorForCategory(String category) {
    int index = _categories.indexOf(category);
    if (index >= 0 && index < _categoryColors.length) {
      return _categoryColors[index];
    } else {
      return Colors.grey;
    }
  }

  void _showAddCategoryDialog() {
    TextEditingController _categoryController = TextEditingController();
    String newCategory = '';
    Color newCategoryColor = _getUniqueColor(); // Obtener un color único

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar nueva categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                decoration:
                    InputDecoration(labelText: 'Nombre de la categoría'),
                onChanged: (value) {
                  newCategory = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  _addCategory(newCategory, newCategoryColor);
                  _updateCategoryColors();
                  _selectedCategory =
                      newCategory; // Actualizar la categoría seleccionada
                  _selectedColor =
                      newCategoryColor; // Actualizar el color seleccionado
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Color _getUniqueColor() {
    // Genera un color aleatorio no repetido
    List<Color> availableColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    for (Color color in _categoryColors) {
      availableColors.remove(color);
    }
    return availableColors.isNotEmpty ? availableColors[0] : Colors.grey;
  }

  void _addNote() {
    setState(() {
      _notes.add(Note(
        _titleController.text,
        _contentController.text,
        _selectedColor,
        _selectedCategory,
      ));
      _titleController.clear();
      _contentController.clear();
      _showAddButton = true; // Mostrar el botón "+" después de agregar una nota
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons
                .other_houses_outlined, // Cambia el ícono de la casita por "Other Houses Outlined"
            color: Colors.grey[800],
            size: 38.0, // Cambia el tamaño del icono a 38.0
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyInicio()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Crea nueva nota',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily:
                        'Headline Medium', // Cambia a FontWeight.w500 para Headline Medium
                  ),
                ),
                SizedBox(width: 8.0),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedColor,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(_selectedCategory),
                  ],
                ),
                SizedBox(width: 8.0),
                _showAddButton
                    ? PopupMenuButton<Map<String, dynamic>>(
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.blue, // Cambia el color a azul
                          size:
                              40.0, // Cambia el tamaño del botón a 36.0 (puedes ajustar el tamaño según tus preferencias)
                        ),
                        onSelected: (Map<String, dynamic> selection) {
                          if (selection['category'] == 'Add') {
                            _showAddCategoryDialog();
                          } else {
                            setState(() {
                              _selectedColor = selection['color'];
                              _selectedCategory = selection['category'];
                              _showAddButton =
                                  false; // Ocultar el botón "+" cuando se selecciona una categoría
                            });
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          List<PopupMenuEntry<Map<String, dynamic>>> items =
                              _categories.map((category) {
                            int index = _categories.indexOf(category);
                            Color color =
                                index >= 0 && index < _categoryColors.length
                                    ? _categoryColors[index]
                                    : Colors.grey;
                            return PopupMenuItem<Map<String, dynamic>>(
                              value: {
                                'color': color,
                                'category': category,
                              },
                              child: CategoryMenuItem(
                                color: color,
                                category: category,
                              ),
                            );
                          }).toList();

                          items.add(PopupMenuItem<Map<String, dynamic>>(
                            value: {
                              'color': _getUniqueColor(),
                              'category': 'Add',
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: Colors.grey[800],
                                ),
                                SizedBox(width: 8.0),
                                Text('Agregar nueva categoría'),
                              ],
                            ),
                          ));

                          return items;
                        },
                      )
                    : SizedBox(), // Espacio en blanco si _showAddButton es falso
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'título',
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
              onPressed: _addNote,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Radio de 12 en los bordes
                ),
              ),
              child: Container(
                width: 150.0,
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
    );
  }
}

class CategoryMenuItem extends StatelessWidget {
  final Color color;
  final String category;

  const CategoryMenuItem({
    Key? key,
    required this.color,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 8.0),
        Text(category),
      ],
    );
  }
}
