import '../../data/models/task_model.dart';

abstract class ITaskRepository {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> toggleComplete(String id);
  Future<void> clearCompleted();
  Future<void> clearAll();
}
