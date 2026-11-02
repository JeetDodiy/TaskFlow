import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_profile.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

class UserProfileNotifier extends Notifier<UserProfile> {
  static const _keyName = 'taskflow_user_name';
  static const _keyEmail = 'taskflow_user_email';
  static const _keyRole = 'taskflow_user_role';
  static const _keyNotif = 'taskflow_notifications_enabled';
  static const _keyJoined = 'taskflow_joined_date';

  @override
  UserProfile build() {
    _loadProfile();
    return UserProfile(joinedDate: DateTime(2026, 10, 1));
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyName) ?? 'Jeet Dodiya';
      final email = prefs.getString(_keyEmail) ?? 'jeet.dodiya@taskflow.dev';
      final role = prefs.getString(_keyRole) ?? 'Productivity Architect';
      final notif = prefs.getBool(_keyNotif) ?? true;
      final joinedStr = prefs.getString(_keyJoined);
      final joined = joinedStr != null
          ? DateTime.tryParse(joinedStr) ?? DateTime(2026, 10, 1)
          : DateTime(2026, 10, 1);

      state = UserProfile(
        name: name,
        email: email,
        role: role,
        notificationsEnabled: notif,
        joinedDate: joined,
      );
    } catch (_) {}
  }

  Future<void> updateProfile({String? name, String? email, String? role}) async {
    final updated = state.copyWith(name: name, email: email, role: role);
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString(_keyName, name);
      if (email != null) await prefs.setString(_keyEmail, email);
      if (role != null) await prefs.setString(_keyRole, role);
    } catch (_) {}
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotif, enabled);
    } catch (_) {}
  }

  Future<void> resetProfile() async {
    final def = UserProfile(joinedDate: DateTime.now());
    state = def;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyName);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyRole);
      await prefs.remove(_keyNotif);
      await prefs.remove(_keyJoined);
    } catch (_) {}
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(() => UserProfileNotifier());

class TaskStatistics {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final double completionRate;
  final Map<String, int> categoryCounts;

  const TaskStatistics({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.completionRate,
    required this.categoryCounts,
  });
}

final taskStatisticsProvider = Provider<TaskStatistics>((ref) {
  final tasks = ref.watch(taskListProvider).value ?? [];
  final total = tasks.length;
  final completed = tasks.where((t) => t.isCompleted).length;
  final pending = tasks.where((t) => !t.isCompleted).length;
  final now = DateTime.now();
  final overdue = tasks.where((t) {
    if (t.isCompleted || t.dueDate == null) return false;
    return t.dueDate!.isBefore(now);
  }).length;
  final completionRate = total == 0 ? 0.0 : (completed / total);

  final categoryCounts = <String, int>{
    'Work': 0,
    'Personal': 0,
    'Study': 0,
    'Urgent': 0,
  };

  for (final task in tasks) {
    if (categoryCounts.containsKey(task.category)) {
      categoryCounts[task.category] = (categoryCounts[task.category] ?? 0) + 1;
    }
  }

  return TaskStatistics(
    total: total,
    completed: completed,
    pending: pending,
    overdue: overdue,
    completionRate: completionRate,
    categoryCounts: categoryCounts,
  );
});
