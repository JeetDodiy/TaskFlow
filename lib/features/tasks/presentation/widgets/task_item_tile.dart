import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_extensions.dart';
import '../../data/models/task_model.dart';
import '../providers/task_providers.dart';

class TaskItemTile extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          ref.read(taskListProvider.notifier).toggleComplete(task.id);
        }),
        children: [
          SlidableAction(
            onPressed: (_) => ref.read(taskListProvider.notifier).toggleComplete(task.id),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: task.isCompleted ? Icons.highlight_off : Icons.check_circle_outline,
            label: task.isCompleted ? 'Mark Pending' : 'Complete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          _deleteTask(context, ref);
        }),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTask(context, ref),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(taskListProvider.notifier).toggleComplete(task.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted ? AppColors.primary : theme.dividerColor,
                          width: 2,
                        ),
                        color: task.isCompleted ? AppColors.primary : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? theme.disabledColor : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.disabledColor,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPriorityColor().withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    size: 12,
                                    color: _getPriorityColor(),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.priority.name.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _getPriorityColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.category,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            if (task.dueDate != null) ...[
                              const Spacer(),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: theme.disabledColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate!.formattedDate,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.disabledColor,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(taskListProvider.notifier);
    notifier.deleteTask(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            notifier.addTask(task);
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
