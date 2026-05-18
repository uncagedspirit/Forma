import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';

/// A shimmering placeholder widget used while data is loading.
///
/// Matches the dimensions of a habit row by default (full width, 56 dp height)
/// and animates a gradient sweep across the surface.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return _SkeletonShimmer(
      width: width ?? double.infinity,
      height: height ?? 56,
      borderRadius: borderRadius ?? AppBorderRadius.small,
    );
  }
}

class _SkeletonShimmer extends StatefulWidget {
  const _SkeletonShimmer({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: const <Color>[
                AppColors.paper2,
                AppColors.paper,
                AppColors.paper2,
              ],
              stops: const <double>[0.0, 0.5, 1.0],
              begin: Alignment(-3 + 4 * _controller.value, 0),
              end: Alignment(-1 + 4 * _controller.value, 0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.paper2,
              borderRadius: widget.borderRadius,
            ),
          ),
        );
      },
    );
  }
}
