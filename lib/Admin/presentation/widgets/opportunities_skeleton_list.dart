import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class OpportunitiesSkeletonList extends StatefulWidget {
  final bool isDark;
  const OpportunitiesSkeletonList({super.key, required this.isDark});

  @override
  State<OpportunitiesSkeletonList> createState() =>
      _OpportunitiesSkeletonListState();
}

class _OpportunitiesSkeletonListState extends State<OpportunitiesSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark ? AppColors.darkCard : AppColors.inputBackground;
    final highlight = widget.isDark ? AppColors.darkBorder : AppColors.border;

    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Container(
          height: 58,
          decoration: BoxDecoration(
            color: Color.lerp(base, highlight, _controller.value),
            borderRadius: BorderRadius.circular(AppColors.radius),
          ),
        ),
      ),
    );
  }
}