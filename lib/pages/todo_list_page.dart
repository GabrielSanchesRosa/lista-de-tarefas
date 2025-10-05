import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/models/task.dart';
import 'package:lista_de_tarefas/repositories/task_repository.dart';
import 'package:lista_de_tarefas/widgets/task_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController tasksController = TextEditingController();
  final TaskRepository taskRepository = TaskRepository();

  List<Task> tasks = [];
  Task? deletedTask;
  int? deletedTaskPos;
  String? errorText;

  @override
  void initState() {
    super.initState();

    taskRepository.getTodoList().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tasksController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Add a task',
                          hintText: 'Ex. Study Flutter',
                          errorText: errorText,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff00d7f3),
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(color: Color(0xff00d7f3)),
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: () {
                        if (tasksController.text.isEmpty) {
                          setState(() {
                            errorText = 'The title cannot be empty!';
                          });

                          return;
                        } else {
                          setState(() {
                            errorText = null;
                          });
                        }

                        setState(() {
                          Task newTask = Task(
                            title: tasksController.text,
                            date: DateTime.now(),
                          );
                          tasks.add(newTask);
                        });
                        tasksController.clear();
                        taskRepository.saveTaskList(tasks);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00d7f3),
                        padding: EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                        ),
                      ),
                      child: Icon(Icons.add, size: 30, color: Colors.white),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Task task in tasks)
                        TaskListItem(task: task, onDelete: onDelete),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text('You have ${tasks.length} pending tasks'),
                    ),

                    SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: () {
                        showDeleteTasksConfirmationDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00d7f3),
                        padding: EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                        ),
                      ),
                      child: Text(
                        'Clean all',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Task task) {
    deletedTask = task;
    deletedTaskPos = tasks.indexOf(task);

    setState(() {
      tasks.remove(task);
    });
    taskRepository.saveTaskList(tasks);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task ${task.title} was deleted!',
          style: TextStyle(color: Color(0xff060708)),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Color(0xff00d7f3),
          onPressed: () {
            setState(() {
              tasks.insert(deletedTaskPos!, deletedTask!);
            });
            taskRepository.saveTaskList(tasks);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDeleteTasksConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
        ),
        title: Text('Clean All?'),
        content: Text('Are you sure you want to delete all tasks?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Text('Cancel', style: TextStyle(color: Color(0xff00d7f3))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTasks();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Text('Clean All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteAllTasks() {
    setState(() {
      tasks.clear();
    });
    taskRepository.saveTaskList(tasks);
  }
}
