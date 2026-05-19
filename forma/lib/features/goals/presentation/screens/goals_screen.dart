import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/presentation/providers/goals_provider.dart';
import 'package:forma/features/goals/presentation/widgets/goal_block.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/shared/widgets/add_flow_sheet.dart';

/// Goals tab — shows all goals with their grouped habits.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      body: SafeArea(
        child: goalsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.sage),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (goals) {
            final active = goals.where((g) => !g.isArchived).toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.contentTop,
                      AppSpacing.screenHorizontal,
                      AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Goals',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showAddFlowSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, size: 16, color: AppColors.paper),
                                const SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.paper,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (active.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyGoals(onAdd: () => showAddFlowSheet(context)),
                  )
                else
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ...active.map((goal) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: GoalBlock(key: ValueKey(goal.id), goal: goal),
                            )),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No goals yet',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'What do you want to achieve in the coming months?',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Add your first goal',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.paper),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
