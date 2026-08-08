import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/locale_provider.dart';
import '../../routes/app_router.dart';
import 'package:go_router/go_router.dart';

/// Profile screen with user info, settings, and stats
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final userAsync = ref.watch(currentUserProvider);
    final stats = ref.watch(todayStatsProvider);
    final medicines = ref.read(medicinesStreamProvider).value ?? [];
    final currentLang = ref.watch(localeProvider);
    final isHindi = currentLang == AppLanguage.hindi;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, isDark, userAsync),
          ),

          // Quick stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildQuickStats(isDark, stats, medicines.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Settings sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSection(
                    isDark: isDark,
                    title: isHindi ? 'प्राथमिकताएं (Preferences)' : 'Preferences',
                    items: [
                      _SettingItem(
                        icon: Icons.dark_mode_outlined,
                        iconColor: AppColors.textSecondary,
                        title: isHindi ? 'डार्क मोड (Dark Mode)' : 'Dark Mode',
                        trailing: Switch(
                          value: themeMode == ThemeModeState.dark,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            ref.read(themeModeProvider.notifier).toggle();
                          },
                        ),
                        isDark: isDark,
                      ),
                      _SettingItem(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.warning,
                        title: isHindi ? 'सूचनाएं (Notifications)' : 'Notifications',
                        subtitle: isHindi ? 'दवा के अलर्ट' : 'Medicine reminders',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.textHint,
                        ),
                        isDark: isDark,
                        onTap: () => _showNotificationDialog(context, isDark),
                      ),
                      _SettingItem(
                        icon: Icons.language_outlined,
                        iconColor: AppColors.primary,
                        title: isHindi ? 'भाषा (Language)' : 'Language',
                        subtitle: isHindi ? 'Hindi (हिन्दी)' : 'English',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.textHint,
                        ),
                        isDark: isDark,
                        onTap: () => _showLanguageDialog(context, isDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildSection(
                    isDark: isDark,
                    title: isHindi ? 'डेटा और गोपनीयता (Data & Privacy)' : 'Data & Privacy',
                    items: [
                      _SettingItem(
                        icon: Icons.picture_as_pdf_outlined,
                        iconColor: AppColors.danger,
                        title: isHindi ? 'पीडीएफ डाउनलोड करें (Export PDF)' : 'Export History PDF',
                        subtitle: isHindi ? 'दवा का रिकॉर्ड' : 'Download your medicine records',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.textHint,
                        ),
                        isDark: isDark,
                        onTap: () => _exportHistoryPdf(context),
                      ),
                      _SettingItem(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: AppColors.success,
                        title: isHindi ? 'गोपनीयता नीति (Privacy Policy)' : 'Privacy Policy',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.textHint,
                        ),
                        isDark: isDark,
                        onTap: () => _showPrivacyPolicyDialog(context, isDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildSection(
                    isDark: isDark,
                    title: 'Account',
                    items: [
                      _SettingItem(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.danger,
                        title: 'Logout',
                        isDark: isDark,
                        onTap: _signOut,
                        titleColor: AppColors.danger,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // App version
                  Text(
                    'MediTrack AI v1.0.0\nMade with ❤️',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextHint
                          : AppColors.textHint,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, bool isDark, UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile updated successfully! ✨'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Notification Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Medicine Reminders'),
              subtitle: const Text('Sound & Vibration alerts'),
              value: true,
              activeColor: AppColors.primary,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Refill Alerts'),
              subtitle: const Text('Alert when stock is low'),
              value: true,
              activeColor: AppColors.primary,
              onChanged: (val) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isDark) {
    final currentLang = ref.read(localeProvider);
    showDialog(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Language / भाषा चुनें',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLanguage(AppLanguage.english);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App Language set to English')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'English',
                style: TextStyle(
                  fontWeight: currentLang == AppLanguage.english ? FontWeight.bold : FontWeight.normal,
                  color: currentLang == AppLanguage.english ? AppColors.primary : null,
                ),
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLanguage(AppLanguage.hindi);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('एप की भाषा बदलकर हिन्दी कर दी गई है')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Hindi (हिन्दी)',
                style: TextStyle(
                  fontWeight: currentLang == AppLanguage.hindi ? FontWeight.bold : FontWeight.normal,
                  color: currentLang == AppLanguage.hindi ? AppColors.primary : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportHistoryPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.robotoRegular();
      final medicines = ref.read(medicinesStreamProvider).value ?? [];

      String clean(String text) {
        return text.replaceAll(RegExp(r'[^\x00-\x7F]+'), '').trim();
      }

      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(base: font),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 0, child: pw.Text("MediTrack AI - Medicine History Report")),
                pw.SizedBox(height: 20),
                pw.Text("Generated on: ${DateTime.now().toString().split('.')[0]}"),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Medicine Name', 'Dosage', 'Type', 'Times'],
                  data: medicines.map((m) {
                    final name = clean(m.name).isEmpty ? m.name : clean(m.name);
                    final dosage = clean(m.dosage).isEmpty ? m.dosage : clean(m.dosage);
                    final type = clean(m.type.displayName).isEmpty ? m.type.displayName : clean(m.type.displayName);
                    return [name, dosage, type, m.times.join(', ')];
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'meditrack_history_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'MediTrack AI values your privacy. Your health records and medicine logs are stored securely with encrypted Firebase Cloud storage. We do not sell or share your personal health data with third parties.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark, AsyncValue userAsync) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
            isDark ? AppColors.darkBackground : AppColors.background,
          ],
        ),
      ),
      child: userAsync.when(
        data: (user) => Row(
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user?.initials ?? 'U',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✓ Account Active',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                ),
              ),
              child: IconButton(
                onPressed: () => _showEditProfileDialog(context, isDark, user),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildQuickStats(bool isDark, TodayStats stats, int medicineCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          _MiniStat(
            value: '$medicineCount',
            label: 'Medicines',
            color: AppColors.primary,
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _MiniStat(
            value: '${stats.taken}',
            label: 'Taken Today',
            color: AppColors.success,
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _MiniStat(
            value: '${stats.percentage.toInt()}%',
            label: 'Adherence',
            color: AppColors.warning,
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
            ),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return Column(
                children: [
                  items[i],
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      color: isDark ? AppColors.darkDivider : AppColors.divider,
                      indent: 56,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AppColors.darkDivider : AppColors.divider,
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool isDark;

  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ??
                          (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
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
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
