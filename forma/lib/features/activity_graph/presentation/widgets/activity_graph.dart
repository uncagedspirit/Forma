import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/activity_graph/domain/entities/activity_graph_data.dart';
import 'package:forma/features/activity_graph/domain/entities/activity_level.dart';
import 'package:forma/features/activity_graph/presentation/providers/activity_graph_provider.dart';
import 'package:forma/shared/widgets/inline_error.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

/// A GitHub-style contribution graph showing 52 weeks of habit completion.
class ActivityGraph extends ConsumerStatefulWidget {
  const ActivityGraph({super.key});

  @override
  ConsumerState<ActivityGraph> createState() => _ActivityGraphState();
}

class _ActivityGraphState extends ConsumerState<ActivityGraph> {
  final ScrollController _scrollController = ScrollController();
  static final Logger _logger = Logger('ActivityGraph');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _scrollController.hasClients &&
          _scrollController.positions.isNotEmpty) {
        try {
          final maxExtent = _scrollController.position.maxScrollExtent;
          if (!MediaQuery.of(context).disableAnimations) {
            _scrollController.animateTo(
              maxExtent,
              duration: AppDurations.normal,
              curve: Curves.easeOut,
            );
          } else {
            _scrollController.jumpTo(maxExtent);
          }
        } catch (e) {
          _logger.warning('Failed to auto-scroll activity graph', e);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime gridEnd = now.add(Duration(days: (7 - now.weekday) % 7));
    final DateTime gridStart = gridEnd.subtract(const Duration(days: 363));

    final graphAsync = ref.watch(activityGraphProvider(gridStart, gridEnd));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: graphAsync.when(
        loading: () => const _ActivityGraphSkeleton(),
        error: (error, stackTrace) {
          _logger.warning('Failed to load activity graph', error, stackTrace);
          return InlineError(
            message: 'Failed to load activity graph',
            onRetry: () => ref.invalidate(activityGraphProvider(gridStart, gridEnd)),
          );
        },
        data: (graphData) => _buildContent(context, graphData, gridStart, now),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<DateTime, ActivityGraphData> graphData,
    DateTime gridStart,
    DateTime now,
  ) {
    const double cellSize = 10.0;
    const double gap = 2.0;
    const double dayLabelWidth = 24.0;
    final bool hasNoData = graphData.values.every((d) => d.level == ActivityLevel.none);
    final DateFormat dateFormat = DateFormat.yMMMd();
    final List<String> dayLabels = ['M', '', 'W', '', 'F', '', ''];
    final List<double> dayLabelHeights = List.generate(7, (i) => i < 6 ? cellSize + gap : cellSize);

    Widget graphContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: dayLabelWidth,
              child: Column(
                children: List.generate(7, (i) {
                  return SizedBox(
                    height: dayLabelHeights[i],
                    child: dayLabels[i].isNotEmpty
                        ? Text(dayLabels[i],
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.ink3))
                        : null,
                  );
                }),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MonthLabels(gridStart: gridStart, cellSize: cellSize, gap: gap),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: List.generate(52, (weekIndex) {
                        return SizedBox(
                          width: cellSize + gap,
                          child: Column(
                            children: List.generate(7, (dayIndex) {
                              final date = gridStart.add(Duration(days: weekIndex * 7 + dayIndex));
                              final normalized = DateTime.utc(date.year, date.month, date.day);
                              final data = graphData[normalized];
                              final level = data?.level ?? ActivityLevel.none;
                              final completed = data?.completed ?? 0;
                              final total = data?.total ?? 0;

                              return Padding(
                                padding: EdgeInsets.only(bottom: dayIndex < 6 ? gap : 0),
                                child: _ActivityCell(
                                  key: ValueKey(date),
                                  date: date,
                                  level: level,
                                  completed: completed,
                                  total: total,
                                  dateFormat: dateFormat,
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (hasNoData) {
      graphContent = Stack(
        children: [
          graphContent,
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: 0.85),
                  borderRadius: AppBorderRadius.regular,
                ),
                child: Text(
                  'Start building your streak history',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink3),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return graphContent;
  }
}

// ---------------------------------------------------------------------------
// Month labels
// ---------------------------------------------------------------------------

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({
    required this.gridStart,
    required this.cellSize,
    required this.gap,
  });

  final DateTime gridStart;
  final double cellSize;
  final double gap;

  String? _labelForWeek(int weekIndex) {
    final weekStart = gridStart.add(Duration(days: weekIndex * 7));
    for (int d = 0; d < 7; d++) {
      final date = weekStart.add(Duration(days: d));
      if (date.day == 1) return _monthAbbrev(date.month);
    }
    return null;
  }

  String _monthAbbrev(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16.0,
      child: Row(
        children: List.generate(52, (weekIndex) {
          final label = _labelForWeek(weekIndex);
          return SizedBox(
            width: cellSize + gap,
            child: label != null
                ? OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(label,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.ink3)),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity cell
// ---------------------------------------------------------------------------

class _ActivityCell extends StatelessWidget {
  const _ActivityCell({
    super.key,
    required this.date,
    required this.level,
    required this.completed,
    required this.total,
    required this.dateFormat,
  });

  final DateTime date;
  final ActivityLevel level;
  final int completed;
  final int total;
  final DateFormat dateFormat;

  Color get _color {
    return switch (level) {
      ActivityLevel.none   => AppColors.graphNone,
      ActivityLevel.light  => AppColors.graphLight,
      ActivityLevel.medium => AppColors.graphMedium,
      ActivityLevel.dark   => AppColors.graphDark,
      ActivityLevel.full   => AppColors.graphFull,
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = total == 0
        ? dateFormat.format(date)
        : '${dateFormat.format(date)} — $completed/$total habits';

    return Tooltip(
      message: label,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
      ),
      textStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.paper),
      child: Semantics(
        label: label,
        child: Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loader
// ---------------------------------------------------------------------------

class _ActivityGraphSkeleton extends StatelessWidget {
  const _ActivityGraphSkeleton();

  @override
  Widget build(BuildContext context) {
    const double cellSize = 10.0;
    const double gap = 2.0;
    const double dayLabelWidth = 24.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: dayLabelWidth),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm + 16.0),
                Row(
                  children: List.generate(52, (weekIndex) {
                    return SizedBox(
                      width: cellSize + gap,
                      child: Column(
                        children: List.generate(7, (dayIndex) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: dayIndex < 6 ? gap : 0),
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: AppColors.paper3,
                                borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
