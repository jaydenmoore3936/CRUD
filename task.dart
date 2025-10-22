import 'dart:convert';

class Task {
  String name;
  bool isCompleted;

  Task({
    required this.name,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}

class TaskListManager {
  static String encode(List<Task> tasks) => json.encode(
        tasks.map((task) => task.toJson()).toList(),
      );

  static List<Task> decode(String tasksString) {
    if (tasksString.isEmpty) return [];
    
    return (json.decode(tasksString) as List<dynamic>)
        .map<Task>((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
