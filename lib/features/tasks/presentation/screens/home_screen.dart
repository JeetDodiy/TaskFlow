import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/presentation/widgets/profile_menu_sheet.dart';
import '../providers/task_providers.dart';
import '../widgets/add_edit_task_sheet.dart';
import '../widgets/task_item_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksState = ref.watch(taskListProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: 'Profile & Settings',
                onPressed: () => _openProfileMenu(context),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'TaskFlow',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.appBarTheme.titleTextStyle?.color,
                ),
              ),
              background: Container(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Productivity Hub',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildProgressIndicator(ref, theme),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _openProfileMenu(context),
                      child: Tooltip(
                        message: 'Profile Menu',
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            profile.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).update(val);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildFilters(ref, theme, selectedCategory, selectedStatus),
          ),
          tasksState.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, st) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
            data: (allTasks) {
              if (allTasks.isEmpty) {
                return _buildEmptyState(
                  theme,
                  'No tasks yet. Tap + to add one.',
                );
              }
              if (filteredTasks.isEmpty) {
                return _buildEmptyState(theme, 'No tasks match your filters.');
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = filteredTasks[index];
                  return TaskItemTile(
                    task: task,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (_) => AddEditTaskSheet(task: task),
                      );
                    },
                  );
                }, childCount: filteredTasks.length),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ), // Bottom padding
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const AddEditTaskSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressIndicator(WidgetRef ref, ThemeData theme) {
    final allTasks = ref.watch(taskListProvider).value ?? [];
    final todayTasks = allTasks.where((t) {
      final now = DateTime.now();
      return t.dueDate != null &&
          t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();

    if (todayTasks.isEmpty) return const SizedBox.shrink();

    final completed = todayTasks.where((t) => t.isCompleted).length;
    final total = todayTasks.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            color: AppColors.primary,
            backgroundColor: theme.dividerColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completed of $total completed today',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(
    WidgetRef ref,
    ThemeData theme,
    String? selectedCategory,
    String selectedStatus,
  ) {
    const statuses = ['All', 'Pending', 'Completed', 'Overdue'];
    const categories = ['Work', 'Personal', 'Study', 'Urgent'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: statuses.map((status) {
              final isSelected = selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (_) {
                    ref.read(selectedStatusProvider.notifier).update(status);
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Categories'),
                selected: selectedCategory == null,
                onSelected: (_) {
                  ref.read(selectedCategoryProvider.notifier).update(null);
                },
                selectedColor: theme.colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 8),
              ...categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).update(cat);
                    },
                    selectedColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: theme.disabledColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
