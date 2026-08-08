import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';
import 'routes/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  await NotificationService().initialize();
  // Request notification permission (required on Android 13+)
  await NotificationService().requestPermissions();

  runApp(
    const ProviderScope(
      child: MediTrackApp(),
    ),
  );
}

/// Root application widget
class MediTrackApp extends ConsumerStatefulWidget {
  const MediTrackApp({super.key});

  @override
  ConsumerState<MediTrackApp> createState() => _MediTrackAppState();
}

class _MediTrackAppState extends ConsumerState<MediTrackApp> {
  StreamSubscription? _notifSub;

  @override
  void initState() {
    super.initState();
    // Listen to foreground notification action buttons
    _notifSub = NotificationService.actionStream.listen((event) {
      final actionId = event['actionId'];
      final payload = event['payload']; // medicine ID
      if (payload == null) return;

      if (actionId == 'TAKEN') {
        // Mark medicine as taken via provider
        final medicines = ref.read(medicinesStreamProvider).value ?? [];
        final med = medicines.where((m) => m.id == payload).firstOrNull;
        if (med != null) {
          ref.read(medicineNotifierProvider.notifier).markDoseTaken(med);
        }
      } else if (actionId == 'SNOOZE') {
        // Schedule snooze notification 10 minutes from now
        final medicines = ref.read(medicinesStreamProvider).value ?? [];
        final med = medicines.where((m) => m.id == payload).firstOrNull;
        if (med != null) {
          NotificationService().snoozeNotification(med);
        }
      }
      // DISMISS: handled by cancelNotification:true on the action
    });

    // Process any "taken" actions from background notification buttons
    _processPendingTaken();
  }

  Future<void> _processPendingTaken() async {
    final pendingIds = await NotificationService.getAndClearPendingTaken();
    if (pendingIds.isEmpty) return;
    // Wait for medicines to load then process
    await Future.delayed(const Duration(seconds: 3));
    final medicines = ref.read(medicinesStreamProvider).value ?? [];
    for (final id in pendingIds) {
      final med = medicines.where((m) => m.id == id).firstOrNull;
      if (med != null) {
        await ref.read(medicineNotifierProvider.notifier).markDoseTaken(med);
      }
    }
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Reschedule notifications for all existing medicines on first load
    ref.listen(medicinesStreamProvider, (prev, next) {
      if ((prev == null || prev.value == null) && next.value != null) {
        final medicines = next.value!;
        final notif = NotificationService();
        for (final med in medicines) {
          if (med.notificationEnabled && !med.isPaused) {
            notif.scheduleNotificationsForMedicine(med);
          }
        }
      }
    });

    final resolvedThemeMode = switch (themeMode) {
      ThemeModeState.light => ThemeMode.light,
      ThemeModeState.dark => ThemeMode.dark,
      ThemeModeState.system => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'MediTrack AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: resolvedThemeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
