import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/activity_graph/presentation/widgets/activity_graph.dart';

/// The stats screen for the Forma habit tracker app.
///
/// Displays the activity graph with a section header and legend.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String yearLabel = DateTime.now().year.toString();

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Your year',
                    style: AppTextStyles.titleLarge,
                  ),
                  Text(
                    yearLabel,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: ActivityGraph(),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _LegendItem(
                    color: AppColors.graphNone,
                    label: 'None',
                  ),
                  SizedBox(width: AppSpacing.md),
                  _LegendItem(
                    color: AppColors.graphLight,
                    label: 'Light',
                  ),
                  SizedBox(width: AppSpacing.md),
                  _LegendItem(
                    color: AppColors.graphMedium,
                    label: 'Medium',
                  ),
                  SizedBox(width: AppSpacing.md),
                  _LegendItem(
                    color: AppColors.graphDark,
                    label: 'Dark',
                  ),
                  SizedBox(width: AppSpacing.md),
                  _LegendItem(
                    color: AppColors.graphFull,
                    label: 'Full',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}
