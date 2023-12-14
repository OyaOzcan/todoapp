import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoapp/models/todo_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('todo_box');
  runApp(MaterialApp(
    title: 'Todo App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.pink),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box<Task> tasksBox;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tasksBox = Hive.box<Task>('todo_box');
  }

  void onAddTask() {
    if (_textEditingController.text.isNotEmpty) {
      final newTask = Task(_textEditingController.text, false);
      tasksBox.add(newTask);
      Navigator.pop(context);
      _textEditingController.clear();
    }
  }

  void onUpdateTask(int index, Task task) {
    tasksBox.putAt(index, Task(task.title, !task.completed));
  }

  void onDeleteTask(int index) {
    tasksBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO LISTS', style: GoogleFonts.bebasNeue(
                  textStyle: TextStyle(fontSize: 34),color: Colors.pink)),
      ),
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box<Task> box, child) {
          if (box.isNotEmpty) {
            return ListView.separated(
              itemBuilder: (context, index) {
                final task = box.getAt(index);

                return Dismissible(
                  key: Key(task!.title),
                  onDismissed: (direction) => onDeleteTask(index),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(task.title),
                      leading: Checkbox(
                        activeColor: Colors.green,
                        value: task.completed,
                        onChanged: (bool? value) => onUpdateTask(index, task),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => onDeleteTask(index),
                      ),
                    ),
                  ),
                );
              },
              itemCount: box.length,
              separatorBuilder: (context, index) => Divider(),
            );
          } else {
            return EmptyList();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Add New Task'),
              content: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(hintText: 'Enter task'),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => onAddTask(),
                  child: Text('SAVE'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Icon(Icons.list_alt_outlined, size: 80.0, color: Colors.pink),
          ),
          Container(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              "Don't have any tasks",
              style: TextStyle(fontSize: 20.0),
            ),
          )
        ],
      ),
    );
  }
}
// oyaselminozcan98