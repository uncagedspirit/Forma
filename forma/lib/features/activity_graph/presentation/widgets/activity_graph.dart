import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/features/activity_graph/domain/entities/activity_graph_data.dart';
import 'package:forma/features/activity_graph/domain/entities/activity_level.dart';
import 'package:forma/features/activity_graph/presentation/providers/activity_graph_provider.dart';
import 'package:forma/features/premium/presentation/providers/premium_status_provider.dart';
import 'package:forma/shared/widgets/inline_error.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

/// A GitHub-style contribution graph widget showing habit completion
/// over the last 52 weeks.
///
/// Displays a 52×7 grid of cells, color-coded by [ActivityLevel].
/// Supports long-press tooltips and premium blur for data older than 30 days.
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
      if (mounted && _scrollController.hasClients) {
        if (!MediaQuery.of(context).disableAnimations) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: AppDurations.normal,
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
    final DateTime gridEnd = now.add(
      Duration(days: (7 - now.weekday) % 7),
    );
    final DateTime gridStart = gridEnd.subtract(
      const Duration(days: 363),
    );
    final AsyncValue<Map<DateTime, ActivityGraphData>> graphAsync = ref.watch(
      activityGraphProvider(gridStart, gridEnd),
    );
    final bool isPremium = ref.watch(premiumStatusProvider);

    return graphAsync.when(
      loading: () => const _ActivityGraphSkeleton(),
      error: (Object error, StackTrace? stackTrace) {
        _logger.warning('Failed to load activity graph', error, stackTrace);
        return InlineError(
          message: 'Failed to load activity graph',
          onRetry: () => ref.invalidate(activityGraphProvider(gridStart, gridEnd)),
        );
      },
      data: (Map<DateTime, ActivityGraphData> graphData) => _buildContent(
        context,
        graphData,
        gridStart,
        now,
        isPremium,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<DateTime, ActivityGraphData> graphData,
    DateTime gridStart,
    DateTime now,
    bool isPremium,
  ) {
    const double cellSize = 10.0;
    const double gap = 2.0;
    const double dayLabelWidth = 24.0;
    final bool hasNoData = graphData.values.every(
      (ActivityGraphData data) => data.level == ActivityLevel.none,
    );
    final DateFormat dateFormat = DateFormat.yMMMd();
    final List<String> dayLabels = <String>['M', '', 'W', '', 'F', '', ''];
    final List<double> dayLabelHeights = <double>[
      cellSize + gap,
      cellSize + gap,
      cellSize + gap,
      cellSize + gap,
      cellSize + gap,
      cellSize + gap,
      cellSize,
    ];

    Widget graphContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: dayLabelWidth,
              child: Column(
                children: List<Widget>.generate(7, (int index) {
                  return SizedBox(
                    height: dayLabelHeights[index],
                    child: dayLabels[index].isNotEmpty
                        ? Text(
                            dayLabels[index],
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.ink3,
                            ),
                          )
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
                  children: <Widget>[
                    _MonthLabels(
                      gridStart: gridStart,
                      cellSize: cellSize,
                      gap: gap,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: List<Widget>.generate(52, (int weekIndex) {
                        return SizedBox(
                          width: cellSize + gap,
                          child: Column(
                            children: List<Widget>.generate(7, (int dayIndex) {
                              final DateTime date = gridStart.add(
                                Duration(
                                  days: weekIndex * 7 + dayIndex,
                                ),
                              );
                              final DateTime normalizedDate = DateTime.utc(
                                date.year,
                                date.month,
                                date.day,
                              );
                              final ActivityGraphData? data =
                                  graphData[normalizedDate];
                              final ActivityLevel level =
                                  data?.level ?? ActivityLevel.none;
                              final int completed = data?.completed ?? 0;
                              final int total = data?.total ?? 0;
                              final DateTime normalizedNow = DateTime.utc(
                                now.year,
                                now.month,
                                now.day,
                              );
                              final int daysOld = normalizedNow
                                  .difference(normalizedDate)
                                  .inDays;
                              final bool isBlurred =
                                  !isPremium && daysOld > 30;

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: dayIndex < 6 ? gap : 0,
                                  ),
                                  child: _ActivityCell(
                                    key: ValueKey(date),
                                    date: date,
                                    level: level,
                                    completed: completed,
                                    total: total,
                                    isBlurred: isBlurred,
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
        if (!isPremium) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _PremiumCta(
            onTap: () => context.push(paywallRoute),
          ),
        ],
      ],
    );

    if (hasNoData) {
      graphContent = Stack(
        children: <Widget>[
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
                  'Start building your history',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.ink3,
                  ),
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
    final DateTime weekStart = gridStart.add(
      Duration(days: weekIndex * 7),
    );
    for (int d = 0; d < 7; d++) {
      final DateTime date = weekStart.add(Duration(days: d));
      if (date.day == 1) {
        return _monthAbbrev(date.month);
      }
    }
    return null;
  }

  String _monthAbbrev(int month) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16.0,
      child: Row(
        children: List<Widget>.generate(52, (int weekIndex) {
          final String? label = _labelForWeek(weekIndex);
          return SizedBox(
            width: cellSize + gap,
            child: label != null
                ? OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.ink3,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ),
    );
  }
}

class _ActivityCell extends StatelessWidget {
  const _ActivityCell({
    super.key,
    required this.date,
    required this.level,
    required this.completed,
    required this.total,
    required this.isBlurred,
    required this.dateFormat,
  });

  final DateTime date;
  final ActivityLevel level;
  final int completed;
  final int total;
  final bool isBlurred;
  final DateFormat dateFormat;

  Color get _color {
    switch (level) {
      case ActivityLevel.none:
        return AppColors.graphNone;
      case ActivityLevel.light:
        return AppColors.graphLight;
      case ActivityLevel.medium:
        return AppColors.graphMedium;
      case ActivityLevel.dark:
        return AppColors.graphDark;
      case ActivityLevel.full:
        return AppColors.graphFull;
    }
  }

  String get _tooltipMessage {
    if (total == 0) {
      return dateFormat.format(date);
    }
    return '${dateFormat.format(date)} — $completed/$total habits';
  }

  @override
  Widget build(BuildContext context) {
    final Widget cell = Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
      ),
    );

    if (isBlurred) {
      return Semantics(
        label:
            '${dateFormat.format(date)}: data blurred, upgrade to see history',
        child: Stack(
          children: <Widget>[
            cell,
            Container(
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(
                color: AppColors.paper.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
              ),
            ),
          ],
        ),
      );
    }

    return Tooltip(
      message: _tooltipMessage,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
      ),
      textStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.paper),
      child: Semantics(
        label:
            '${dateFormat.format(date)}: $completed of $total habits completed',
        child: cell,
      ),
    );
  }
}

class _PremiumCta extends StatelessWidget {
  const _PremiumCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Upgrade to see full history',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.terra,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '→',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.terra,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityGraphSkeleton extends StatelessWidget {
  const _ActivityGraphSkeleton();

  @override
  Widget build(BuildContext context) {
    const double cellSize = 10.0;
    const double gap = 2.0;
    const double dayLabelWidth = 24.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(width: dayLabelWidth),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: AppSpacing.sm + 16.0, // Month label area
                ),
                Row(
                  children: List<Widget>.generate(52, (int weekIndex) {
                    return SizedBox(
                      width: cellSize + gap,
                      child: Column(
                        children: List<Widget>.generate(7, (int dayIndex) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: dayIndex < 6 ? gap : 0,
                            ),
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: AppColors.paper3,
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.rSm,
                                ),
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


