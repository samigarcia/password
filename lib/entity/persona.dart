// es unaa clase para crear un objeto persona
class Persona {
  int id = 0;
  String name = "";
  String password = "";
  String rpassword = "";
  String res = "";

  Persona(
      {required this.id,
      required this.name,
      required this.password,
      required this.rpassword,
      required this.res});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'rpassword': rpassword,
      'res': res
    };
  }

  factory Persona.fromMap(Map<String, dynamic> json) => Persona(
      id: 1,
      name: 'name',
      password: 'password',
      rpassword: 'rpassword',
      res: 'res');
}
