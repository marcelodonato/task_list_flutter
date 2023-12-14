class Task {
  late String name;
  late DateTime date;
  late bool concluded;

  Task(this.name) {
    date = DateTime.now();
    concluded = false;
  }
}
