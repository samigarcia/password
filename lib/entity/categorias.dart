class Category {
  int? id; // El ID de la categoría (puede ser nulo si es una nueva categoría).
  String name; // El nombre de la categoría.
  int color; // El color asociado a la categoría.

  Category({
    this.id, // Constructor para crear una nueva categoría.
    required this.name,  // El nombre de la categoría es obligatorio.
    required this.color, // El color de la categoría es obligatorio.
  });

  Map<String, dynamic> toMap() {
    return {
      // Convierte la categoría a un mapa de atributos.
      'id': id,
      'name': name,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> json) => Category(
    // crea una categoría a partir de un mapa.
    id: json['id'],
    name: json['name'],
    color: json['color'],
  );
}