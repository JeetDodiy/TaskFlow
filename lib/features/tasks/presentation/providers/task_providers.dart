import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/i_task_repository.dart';

// Repository Provider
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  return TaskRepositoryImpl();
});

// Task List AsyncNotifier
class TaskListNotifier extends AsyncNotifier<List<TaskModel>> {
  late final ITaskRepository _repository;

  @override
  Future<List<TaskModel>> build() async {
    _repository = ref.watch(taskRepositoryProvider);
    return _fetchTasks();
  }

  Future<List<TaskModel>> _fetchTasks() async {
    final tasks = await _repository.getTasks();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  Future<void> addTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addTask(task);
      return _fetchTasks();
    });
  }

  Future<void> updateTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateTask(task);
      return _fetchTasks();
    });
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTask(id);
      return _fetchTasks();
    });
  }

  Future<void> toggleComplete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.toggleComplete(id);
      return _fetchTasks();
    });
  }

  Future<void> clearCompleted() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.clearCompleted();
      return _fetchTasks();
    });
  }

  Future<void> clearAll() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.clearAll();
      return _fetchTasks();
    });
  }
}

final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<TaskModel>>(() {
  return TaskListNotifier();
});

// Filters using Notifier
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? category) => state = category;
}
final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String?>(() => SelectedCategoryNotifier());

class SelectedStatusNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void update(String status) => state = status;
}
final selectedStatusProvider = NotifierProvider<SelectedStatusNotifier, String>(() => SelectedStatusNotifier());

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskListProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final status = ref.watch(selectedStatusProvider);

  return tasks.where((task) {
    // Text search
    final matchesQuery = task.title.toLowerCase().contains(query) || 
                         (task.description?.toLowerCase().contains(query) ?? false);
    if (!matchesQuery) return false;

    // Category filter
    if (category != null && task.category != category) return false;

    // Status filter
    final now = DateTime.now();
    switch (status) {
      case 'Pending':
        if (task.isCompleted) return false;
        break;
      case 'Completed':
        if (!task.isCompleted) return false;
        break;
      case 'Overdue':
        if (task.isCompleted) return false;
        if (task.dueDate == null) return false;
        if (task.dueDate!.isAfter(now)) return false;
        break;
      case 'All':
      default:
        break;
    }
    return true;
  }).toList();
});
