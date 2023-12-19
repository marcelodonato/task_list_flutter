import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_list/auth_service.dart';
import 'package:task_list/task_entity.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

final databaseReference = FirebaseDatabase.instance.reference();

class _ListScreenState extends State<ListScreen> {
  List<Task> tarefas = [];
  TextEditingController textFieldController = TextEditingController();
  String message = '';
  bool isAddingTask = false;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    databaseReference.child("tasks").onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        try {
          Map<dynamic, dynamic> taskData =
              snapshot.value as Map<dynamic, dynamic>;

          List<Task> loadedTasks = taskData.entries.map((entry) {
            Map<dynamic, dynamic> data = entry.value;
            String taskId = entry.key;

            return Task(
              taskId,
              data['message'],
              DateTime.parse(data['date']),
              data['concluded'],
            );
          }).toList();

          setState(() {
            tarefas = loadedTasks;
          });
        } catch (error) {
          print("Erro ao carregar tarefas: $error");
        }
      }
    });
  }

  void updateTaskCompletion(int index) async {
    String taskId = tarefas[index].id;
    DatabaseReference taskRef = databaseReference.child('tasks').child(taskId);

    try {
      await taskRef.update({'concluded': !tarefas[index].concluded});
    } catch (error) {
      print("Erro ao atualizar estado da tarefa: $error");
      return;
    }

    setState(() {
      tarefas[index].concluded = !tarefas[index].concluded;
    });
  }

  void addTask() async {
    if (message.isNotEmpty && !isAddingTask) {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String randomPart =
          DateTime.now().microsecondsSinceEpoch.remainder(1000).toString();
      String taskId = '$timestamp$randomPart';

      DatabaseReference tasksRef =
          databaseReference.child('tasks').child(taskId);

      setState(() {
        isAddingTask = true;
      });

      try {
        await tasksRef
            .set(Task(taskId, message, DateTime.now(), false).toMap());

        setState(() {
          tarefas.insert(0, Task(taskId, message, DateTime.now(), false));
          textFieldController.clear();
          message = '';
        });
      } catch (error) {
        print("Erro ao adicionar tarefa: $error");
      } finally {
        setState(() {
          isAddingTask = false;
        });
      }
    }
  }

  void removeTask(int index) async {
    String taskId = tarefas[index].id;
    DatabaseReference taskRef = databaseReference.child('tasks').child(taskId);

    try {
      await taskRef.remove();
    } catch (error) {
      print("Erro ao remover tarefa: $error");
      return;
    }

    setState(() {
      tarefas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        title: const Text("Lista de tarefas"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Sair do App",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: "Sair do app",
                  onPressed: () => context.read<AuthService>().logout(),
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: textFieldController,
                          onChanged: (value) {
                            setState(() {
                              message = value;
                            });
                          },
                          decoration: const InputDecoration(
                        
                            hintText: 'Digite sua tarefa aqui',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),        
                Container(
                  margin: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isAddingTask ? null : addTask,
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(
                              255, 173, 216, 230), // Azul claro
                        ),
                        child: const Text(
                          'Adicionar tarefa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tarefas.isEmpty
                ? const Center(child: Text('Sem tarefas disponíveis'))
                : ListView.builder(
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(tarefas[index].date.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: AlignmentDirectional.centerStart,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: AlignmentDirectional.centerEnd,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          removeTask(index);
                        },
                        direction: DismissDirection.horizontal,
                        child: ListTile(
                          title: Text(tarefas[index].message),
                          subtitle: Text(
                            'Data: ${DateFormat('dd/MM/yyyy').format(tarefas[index].date)} - Concluída: ${tarefas[index].concluded == true ? "Sim" : "Não"}',
                          ),
                          trailing: Checkbox(
                            value: tarefas[index].concluded,
                            onChanged: (value) {
                              updateTaskCompletion(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
