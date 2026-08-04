import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';

/// Beautiful medicine card with swipe actions
class MedicineCard extends ConsumerStatefulWidget {
  final MedicineModel medicine;
  final bool showTakeButton;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int? animationIndex;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.showTakeButton = false,
    this.onEdit,
    this.onDelete,
    this.animationIndex,
  });

  @override
  ConsumerState<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends ConsumerState<MedicineCard>
    with SingleTickerProviderStateMixin {
  bool _isTaking = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _markTaken() async {
    // Play custom drinking sound + strong haptic when medicine is taken
    try {
      await _audioPlayer.play(AssetSource('sounds/medicine_taken.mp3'));
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
    HapticFeedback.heavyImpact();
    setState(() => _isTaking = true);
    await ref.read(medicineNotifierProvider.notifier).markDoseTaken(widget.medicine);
    if (mounted) {
      setState(() => _isTaking = false);
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.medicine.name} marked as taken! 💪',
            style: GoogleFonts.outfit(fontSize: 14),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final medicine = widget.medicine;
    final todayStatus = medicine.getTodayStatus();

    Widget card = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: medicine.isPaused
                    ? AppColors.textHint.withOpacity(0.3)
                    : isDark
                        ? AppColors.darkCardBorder
                        : AppColors.cardBorder,
              ),
            ),
            child: Row(
              children: [
                // Medicine icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: medicine.isPaused
                        ? AppColors.textHint.withOpacity(0.1)
                        : medicine.type.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      medicine.isPaused ? '⏸️' : medicine.type.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: medicine.isPaused
                              ? (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary)
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${medicine.dosage} · ${medicine.type.displayName}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Times row
                      Wrap(
                        spacing: 6,
                        children: medicine.times
                            .take(3)
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    t,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status / Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (medicine.isPaused)
                          _StatusBadge(
                              label: 'Paused', color: AppColors.textSecondary)
                        else if (todayStatus == DoseStatus.taken)
                          _StatusBadge(label: 'Taken', color: AppColors.success)
                        else if (todayStatus == DoseStatus.missed)
                          _StatusBadge(label: 'Missed', color: AppColors.danger)
                        else if (widget.showTakeButton)
                          _TakeButton(
                            isLoading: _isTaking,
                            onTap: _markTaken,
                          )
                        else
                          _StatusBadge(label: 'Pending', color: AppColors.warning),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 20,
                            color: isDark ? AppColors.darkTextHint : AppColors.textHint,
                          ),
                          onSelected: (val) async {
                            if (val == 'pause') {
                              ref.read(medicineNotifierProvider.notifier).togglePause(medicine);
                            } else if (val == 'edit') {
                              widget.onEdit?.call();
                            } else if (val == 'delete') {
                              final confirm = await _showDeleteDialog();
                              if (confirm == true) {
                                ref.read(medicineNotifierProvider.notifier).deleteMedicine(medicine.id);
                              }
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'pause',
                              child: Row(
                                children: [
                                  Icon(medicine.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(medicine.isPaused ? 'Resume' : 'Pause'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppColors.danger)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Wrap with Dismissible for swipe actions
    return Dismissible(
      key: ValueKey(medicine.id),
      background: _SwipeBackground(
        color: AppColors.primary,
        icon: Icons.edit_outlined,
        label: 'Edit',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBackground(
        color: AppColors.danger,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit swipe
          HapticFeedback.mediumImpact();
          widget.onEdit?.call();
          return false;
        } else {
          // Delete swipe
          HapticFeedback.heavyImpact();
          return await _showDeleteDialog();
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          ref
              .read(medicineNotifierProvider.notifier)
              .deleteMedicine(medicine.id);
        }
      },
      child: card,
    ).animate(delay: Duration(milliseconds: (widget.animationIndex ?? 0) * 80)).fadeIn(duration: 400.ms).slideX(begin: 0.05);
  }

  Future<bool?> _showDeleteDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final _ = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            'Delete Medicine?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.medicine.name}"? This action cannot be undone.',
            style: GoogleFonts.outfit(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _TakeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _TakeButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Take',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Align(
          alignment: alignment,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (alignment == Alignment.centerRight) ...[
                Text(label,
                    style: GoogleFonts.outfit(
                        color: color, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Icon(icon, color: color),
              ] else ...[
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(label,
                    style: GoogleFonts.outfit(
                        color: color, fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
