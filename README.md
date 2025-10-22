import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/task.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListScreen();
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  ThemeMode _themeMode = ThemeMode.light; 


  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

    if (mounted) {
      setState(() {
        if (tasksString != null) {
          _tasks = TaskListManager.decode(tasksString);
        }
        _sortTasks(); 
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = TaskListManager.encode(_tasks);
    await prefs.setString('tasks', tasksString);
  }
  
  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }


  void _sortTasks() {
    _tasks.sort((a, b) {
      final int aValue = a.isCompleted ? 1 : 0;
      final int bValue = b.isCompleted ? 1 : 0;
      return aValue.compareTo(bValue);
    });
  }

  void _addTask() {
    final String taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      setState(() {
        final newTask = Task(name: taskName);
        _tasks.add(newTask);
        _taskController.clear();
        _sortTasks();
        _saveTasks();
      });
    }
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      _sortTasks();
      _saveTasks();
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
      _saveTasks();
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      _saveTheme(_themeMode == ThemeMode.dark);
    });
  }


  Widget _buildTaskItem(Task task) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) => _toggleTaskCompletion(task),
          activeColor: Theme.of(context).primaryColor,
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontStyle: task.isCompleted ? FontStyle.italic : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _deleteTask(task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ToDo CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        appBarTheme: AppBarTheme(backgroundColor: Colors.indigo.shade700, foregroundColor: Colors.white),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade900),
        cardColor: Colors.grey.shade800,
      ),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Task Manager'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(_themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
              onPressed: _toggleTheme,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Enter new task name',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _taskController.clear(),
                        ),
                      ),
                      onSubmitted: (_) => _addTask(), 
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _addTask,
                    elevation: 0,
                    mini: true,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_box_outline_blank, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          const Text('All tasks complete! Add a new task above.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskItem(_tasks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
