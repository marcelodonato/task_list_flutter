import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_list/task_entity.dart';
import 'task_item.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

final databaseReference = FirebaseDatabase.instance.reference();

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

class _ListScreenState extends State<ListScreen> {
  List<Task> tarefas = [];
  TextEditingController textFieldController = TextEditingController();
  String message = '';

  void addTask() async {
    if (message.isNotEmpty) {
      setState(() {
        tarefas.add(Task(message));
        textFieldController.clear();
        message = '';
      });

      databaseReference.child('tasks').set({
        'message': tarefas.first.name,
        // 'date': formatDate(tarefas.first.date),
        'concluded': tarefas.first.concluded,
      });
    }
  }

  void removeTask(int index) {
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textFieldController,
                    onChanged: (value) {
                      setState(() {
                        message = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: tarefas[index],
                  onTap: () {
                    setState(() {
                      tarefas[index].concluded = !tarefas[index].concluded;
                    });
                  },
                  onDismissed: () {
                    removeTask(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
