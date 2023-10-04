// Define una clase `Notea` para representar las notas
class Notea {
  final int? id; // ID de la nota (puede ser nulo para notas nuevas)
  final String title; // Título de la nota
  late final String content; // Contenido de la nota
  int categoryId;
  //final String iv; // Agrega un campo para el IV

  // Constructor de la clase `Notea`
  Notea({
    this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    //required this.iv,
  });

  // Convierte una instancia de `Notea` a un mapa (para su almacenamiento en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      //'iv': iv,
    };
  }

  // Constructor de fábrica para crear una instancia de `Notea` a partir de un mapa
  factory Notea.fromMap(Map<String, dynamic> json) => Notea (
    id: json['id'],
    title: json['title'], // Valor predeterminado si es nulo
    content: json['content'], // Valor predeterminado si es nulo
    categoryId: json['category_id'], // Valor predeterminado si es nulo
    //iv: json['iv'],
  );
}