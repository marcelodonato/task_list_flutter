import 'package:intl/intl.dart';

class Task {
  late String id; // Novo campo para armazenar o ID
  late String message;
  late DateTime date;
  late bool concluded;

  Task(this.id, this.message, this.date, this.concluded);

  factory Task.fromMap(String id, Map<dynamic, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('Map cannot be null');
    }

    // Extraia as chaves dos subnós
    String message = map['message'] ?? '';
    String dateStr = map['date'] ?? '';
    bool concluded = map['concluded'] ?? false;

    // Crie uma instância de DateTime a partir da string de data
    DateTime date = DateFormat('dd/MM/yyyy').parse(dateStr);

    return Task(id, message, date, concluded);
  }

  // Método para converter a tarefa em um mapa para armazenamento no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'date': DateFormat('dd/MM/yyyy').format(date),
      'concluded': concluded,
    };
  }
}