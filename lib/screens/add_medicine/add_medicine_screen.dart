import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/common/animated_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Full-featured add/edit medicine form
class AddMedicineScreen extends ConsumerStatefulWidget {
  final MedicineModel? medicine;

  const AddMedicineScreen({super.key, this.medicine});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  MedicineType _selectedType = MedicineType.tablet;
  MedicineFrequency _selectedFrequency = MedicineFrequency.daily;
  MealPreference _selectedMeal = MealPreference.anytime;
  List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _notificationEnabled = true;

  bool get _isEditing => widget.medicine != null;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final m = widget.medicine!;
      _nameController.text = m.name;
      _dosageController.text = m.dosage;
      _notesController.text = m.notes ?? '';
      _selectedType = m.type;
      _selectedFrequency = m.frequency;
      _selectedMeal = m.mealPreference;
      _startDate = m.startDate;
      _endDate = m.endDate;
      _notificationEnabled = m.notificationEnabled;
      _reminderTimes = m.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _reminderTimes.add(picked));
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: isStart ? DateTime(2020) : _startDate,
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one reminder time.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();

    final medicine = MedicineModel(
      id: _isEditing ? widget.medicine!.id : const Uuid().v4(),
      userId: '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      type: _selectedType,
      frequency: _selectedFrequency,
      times: _reminderTimes.map(_formatTime).toList()..sort(),
      mealPreference: _selectedMeal,
      startDate: _startDate,
      endDate: _endDate,
      notificationEnabled: _notificationEnabled,
      takenHistory: _isEditing ? widget.medicine!.takenHistory : [],
      createdAt: _isEditing ? widget.medicine!.createdAt : DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (_isEditing) {
      await ref.read(medicineNotifierProvider.notifier).updateMedicine(medicine);
    } else {
      await ref.read(medicineNotifierProvider.notifier).addMedicine(medicine);
    }

    final state = ref.read(medicineNotifierProvider);
    if (mounted) {
      state.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.danger,
            ),
          );
        },
        data: (_) async {
          HapticFeedback.heavyImpact();
          setState(() => _showSuccess = true);
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) context.pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(medicineNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _showSuccess
                    ? _buildSuccessView(isDark)
                    : _buildForm(isDark, isLoading),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isEditing ? 'Edit Medicine' : 'Add Medicine',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('✅', style: TextStyle(fontSize: 50)),
            ),
          ).animate().scale(begin: const Offset(0, 0), duration: 600.ms,
              curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            _isEditing ? 'Medicine Updated!' : 'Medicine Added! 🎉',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDark, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Basic Info
          _SectionHeader(title: 'Medicine Info', isDark: isDark),
          const SizedBox(height: 12),

          CustomTextField(
            controller: _nameController,
            label: AppStrings.medicineName,
            hint: 'e.g., Vitamin C',
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.medication_outlined),
            validator: (v) =>
                v == null || v.isEmpty ? AppStrings.errorEmptyField : null,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 16),

          CustomTextField(
            controller: _dosageController,
            label: AppStrings.dosage,
            hint: 'e.g., 500mg',
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.scale_outlined),
            validator: (v) =>
                v == null || v.isEmpty ? AppStrings.errorEmptyField : null,
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Medicine Type
          _SectionHeader(title: 'Medicine Type', isDark: isDark),
          const SizedBox(height: 12),

          _MedicineTypeSelector(
            selected: _selectedType,
            onChanged: (t) => setState(() => _selectedType = t),
            isDark: isDark,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Frequency
          _SectionHeader(title: 'Frequency', isDark: isDark),
          const SizedBox(height: 12),

          _FrequencySelector(
            selected: _selectedFrequency,
            onChanged: (f) => setState(() => _selectedFrequency = f),
            isDark: isDark,
          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Reminder Times
          _SectionHeader(title: 'Reminder Times', isDark: isDark),
          const SizedBox(height: 12),

          _ReminderTimesSection(
            times: _reminderTimes,
            onAdd: _addTime,
            onRemove: (i) => setState(() => _reminderTimes.removeAt(i)),
            isDark: isDark,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Meal Preference
          _SectionHeader(title: 'Meal Preference', isDark: isDark),
          const SizedBox(height: 12),

          _MealPreferenceSelector(
            selected: _selectedMeal,
            onChanged: (m) => setState(() => _selectedMeal = m),
            isDark: isDark,
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Date Range
          _SectionHeader(title: 'Duration', isDark: isDark),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _DatePickerButton(
                  label: 'Start Date',
                  date: _startDate,
                  onTap: () => _pickDate(true),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DatePickerButton(
                  label: 'End Date',
                  date: _endDate,
                  hint: 'Ongoing',
                  onTap: () => _pickDate(false),
                  isDark: isDark,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Notes
          CustomTextField(
            controller: _notesController,
            label: 'Notes (optional)',
            hint: 'Any special instructions...',
            maxLines: 3,
            prefixIcon: const Icon(Icons.notes_rounded),
          ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Notification toggle
          _NotificationToggle(
            enabled: _notificationEnabled,
            onChanged: (v) => setState(() => _notificationEnabled = v),
            isDark: isDark,
          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

          const SizedBox(height: 32),

          // Save button
          AnimatedButton(
            onPressed: isLoading ? null : _save,
            isLoading: isLoading,
            gradient: AppColors.primaryGradient,
            child: Text(
              _isEditing ? 'Update Medicine' : AppStrings.addMedicine,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }
}

class _MedicineTypeSelector extends StatelessWidget {
  final MedicineType selected;
  final Function(MedicineType) onChanged;
  final bool isDark;

  const _MedicineTypeSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: MedicineType.values.map((type) {
        final isSelected = selected == type;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color.withOpacity(0.15)
                  : (isDark ? AppColors.darkCard : AppColors.card),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? type.color
                    : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  type.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? type.color
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  final MedicineFrequency selected;
  final Function(MedicineFrequency) onChanged;
  final bool isDark;

  const _FrequencySelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MedicineFrequency.values.map((freq) {
        final isSelected = selected == freq;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(freq),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkCard : AppColors.card),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
                ),
              ),
              child: Text(
                freq.displayName,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ReminderTimesSection extends StatelessWidget {
  final List<TimeOfDay> times;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final bool isDark;

  const _ReminderTimesSection({
    required this.times,
    required this.onAdd,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...List.generate(times.length, (i) {
              final t = times[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (times.length > 1) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onRemove(i),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.primary.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkInputBorder : AppColors.inputBorder,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Add Time',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealPreferenceSelector extends StatelessWidget {
  final MealPreference selected;
  final Function(MealPreference) onChanged;
  final bool isDark;

  const _MealPreferenceSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      (MealPreference.beforeMeal, '🕐', 'Before Meal'),
      (MealPreference.afterMeal, '🕓', 'After Meal'),
      (MealPreference.anytime, '⏰', 'Anytime'),
    ];

    return Row(
      children: options.map((o) {
        final (pref, emoji, label) = o;
        final isSelected = selected == pref;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(pref),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.success.withOpacity(0.12)
                    : (isDark ? AppColors.darkCard : AppColors.card),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.success
                      : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.success
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? hint;
  final VoidCallback onTap;
  final bool isDark;

  const _DatePickerButton({
    required this.label,
    required this.date,
    this.hint,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkInputBorder : AppColors.inputBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? DateFormat('MMM d, yyyy').format(date!)
                      : (hint ?? 'Select'),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: date != null
                        ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary)
                        : (isDark
                            ? AppColors.darkTextHint
                            : AppColors.textHint),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final bool enabled;
  final Function(bool) onChanged;
  final bool isDark;

  const _NotificationToggle({
    required this.enabled,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.enableReminder,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Get notified at reminder times',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
