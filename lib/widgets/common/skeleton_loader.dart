import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

/// Loading skeleton widget for medicine cards
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEEF1F5),
      highlightColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height ?? 16,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Full medicine card skeleton
class MedicineCardSkeleton extends StatelessWidget {
  const MedicineCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEEF1F5),
      highlightColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 64,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard skeleton
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SkeletonLoader(height: 180, borderRadius: 24),
          const SizedBox(height: 20),
          const SkeletonLoader(height: 120, borderRadius: 20),
          const SizedBox(height: 20),
          const SkeletonLoader(height: 60, borderRadius: 16),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 60, borderRadius: 16),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 60, borderRadius: 16),
        ],
      ),
    );
  }
}
