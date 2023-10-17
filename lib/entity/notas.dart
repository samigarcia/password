class Notea {
  final int? id; // El ID de la nota (puede ser nulo si es una nueva nota).
  final String title; // El título de la nota.
  final String content; // El contenido de la nota.
  final int categoryId; // El ID de la categoría a la que pertenece la nota.
  final String iv; // El IV (Initialization Vector) utilizado en la encriptación.

  Notea({
    this.id, // Constructor para crear una nueva nota.
    required this.title, // El título de la nota es obligatorio.
    required this.content, // El contenido de la nota es obligatorio.
    required this.categoryId, // El ID de la categoría es obligatorio.
    required this.iv, // El IV es obligatorio.
  });

  Map<String, dynamic> toMap() {
    return {
      // Convierte la nota a un mapa de atributos.
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'iv': iv, // Incluye el IV en el mapa
    };
  }

  factory Notea.fromMap(Map<String, dynamic> json) => Notea(
    // crea una nota a partir de un mapa.
    id: json['id'],
    title: json['title'],
    content: json['content'],
    categoryId: json['category_id'],
    iv: json['iv'], // Obtiene el IV del mapa
  );
}
