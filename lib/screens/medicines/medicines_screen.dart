import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/medicine_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/medicine/medicine_card.dart';

/// Medicine list screen with search and filters
class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  final _filters = [
    MedicineFilter.all,
    MedicineFilter.today,
    MedicineFilter.upcoming,
    MedicineFilter.completed,
    MedicineFilter.missed,
  ];

  final _filterLabels = ['All', 'Today', 'Upcoming', 'Taken', 'Missed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(medicineFilterProvider.notifier).state =
            _filters[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final medicines = ref.watch(searchedMedicinesProvider);
    final medicinesAsync = ref.watch(medicinesStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.medicines,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  // Medicine count badge
                  medicinesAsync.when(
                    data: (meds) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${meds.length} medicines',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
                style: GoogleFonts.outfit(fontSize: 15),
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),

            const SizedBox(height: 16),

            // Filter tabs
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (ctx, i) => _FilterChip(
                  label: _filterLabels[i],
                  isSelected:
                      ref.watch(medicineFilterProvider) == _filters[i],
                  onTap: () {
                    ref.read(medicineFilterProvider.notifier).state = _filters[i];
                  },
                  isDark: isDark,
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            const SizedBox(height: 12),

            // Medicine list
            Expanded(
              child: medicinesAsync.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (_, __) => const MedicineCardSkeleton(),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error loading medicines',
                    style: GoogleFonts.outfit(color: AppColors.danger),
                  ),
                ),
                data: (_) {
                  if (medicines.isEmpty) {
                    return EmptyStateWidget(
                      title: AppStrings.noMedicines,
                      description: AppStrings.noMedicinesDesc,
                      emoji: '💊',
                      action: ElevatedButton.icon(
                        onPressed: () => context.push(Routes.addMedicine),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Medicine'),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: medicines.length,
                    itemBuilder: (ctx, i) => MedicineCard(
                      medicine: medicines[i],
                      animationIndex: i,
                      onEdit: () => context.push(
                        Routes.editMedicine,
                        extra: medicines[i],
                      ),
                      onDelete: () async {
                        await ref
                            .read(medicineNotifierProvider.notifier)
                            .deleteMedicine(medicines[i].id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : AppColors.card),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
