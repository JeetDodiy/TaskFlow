import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../../domain/repositories/i_task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  static const String boxName = 'tasks_box';
  
  Box<TaskModel> get _box => Hive.box<TaskModel>(boxName);

  @override
  Future<List<TaskModel>> getTasks() async {
    return _box.values.toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> toggleComplete(String id) async {
    final task = _box.get(id);
    if (task != null) {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _box.put(id, updatedTask);
    }
  }

  @override
  Future<void> clearCompleted() async {
    final idsToDelete = _box.values
        .where((t) => t.isCompleted)
        .map((t) => t.id)
        .toList();
    await _box.deleteAll(idsToDelete);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}
