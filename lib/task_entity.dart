import 'package:intl/intl.dart';

class Task {
  late String id; 
  late String message;
  late DateTime date;
  late bool concluded;

  Task(this.id, this.message, this.date, this.concluded);

  factory Task.fromMap(String id, Map<dynamic, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('Map cannot be null');
    }

    String message = map['message'] ?? '';
    String dateStr = map['date'] ?? '';
    bool concluded = map['concluded'] ?? false;

    DateTime date = DateFormat('dd/MM/yyyy').parse(dateStr);

    return Task(id, message, date, concluded);
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'date': DateFormat('dd/MM/yyyy').format(date),
      'concluded': concluded,
    };
  }
}