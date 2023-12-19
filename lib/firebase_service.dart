import 'package:firebase_database/firebase_database.dart';
import 'package:task_list/task_entity.dart';

class FirebaseService {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  Future<List<Task>> loadTasks() async {
    final event = await _databaseReference.child("tasks").once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
      try {
        Map<dynamic, dynamic> taskData =
            snapshot.value as Map<dynamic, dynamic>;

        return taskData.entries.map((entry) {
          Map<dynamic, dynamic> data = entry.value;
          String taskId = entry.key;

          return Task(
            taskId,
            data['message'],
            DateTime.parse(data['date']),
            data['concluded'],
          );
        }).toList();
      } catch (error) {
        print("Erro ao carregar tarefas: $error");
      }
    }

    return [];
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    DatabaseReference taskRef = _databaseReference.child('tasks').child(taskId);

    try {
      await taskRef.update({'concluded': isCompleted});
    } catch (error) {
      print("Erro ao atualizar estado da tarefa: $error");
      rethrow;
    }
  }

  Future<void> addTask(String message) async {
    if (message.isNotEmpty) {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String randomPart =
          DateTime.now().microsecondsSinceEpoch.remainder(1000).toString();
      String taskId = '$timestamp$randomPart';

      DatabaseReference tasksRef =
          _databaseReference.child('tasks').child(taskId);

      try {
        await tasksRef
            .set(Task(taskId, message, DateTime.now(), false).toMap());
      } catch (error) {
        print("Erro ao adicionar tarefa: $error");
        rethrow;
      }
    }
  }

Future<void> removeTask(String taskId) async {
  DatabaseReference taskRef = _databaseReference.child('tasks').child(taskId);

  try {
    await taskRef.remove();
    print("Tarefa removida com sucesso: $taskId");
  } catch (error) {
    print("Erro ao remover tarefa: $error");
    rethrow;
  }
}
}
