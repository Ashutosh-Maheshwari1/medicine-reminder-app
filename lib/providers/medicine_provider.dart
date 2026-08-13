import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';
import '../core/services/notification_service.dart';
import 'auth_provider.dart';

const _uuid = Uuid();

/// Medicine list provider - real-time stream from Firestore
final medicinesStreamProvider = StreamProvider<List<MedicineModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return MedicineRepository().watchMedicines(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Today's medicines provider
final todayMedicinesProvider = Provider<List<MedicineModel>>((ref) {
  final medicines = ref.watch(medicinesStreamProvider).value ?? [];
  return medicines.where((m) => m.isActiveToday).toList();
});

/// Today's stats provider
final todayStatsProvider = Provider<TodayStats>((ref) {
  final medicines = ref.watch(todayMedicinesProvider);
  int taken = 0;
  int missed = 0;
  int upcoming = 0;
  int total = 0;

  for (final med in medicines) {
    final dosesPerDay = med.times.length;
    total += dosesPerDay;
    final takenToday = med.takenHistory.where((r) {
      final now = DateTime.now();
      return r.scheduledTime.year == now.year &&
          r.scheduledTime.month == now.month &&
          r.scheduledTime.day == now.day &&
          r.status == DoseStatus.taken;
    }).length;
    taken += takenToday;
    missed += med.takenHistory.where((r) {
      final now = DateTime.now();
      return r.scheduledTime.year == now.year &&
          r.scheduledTime.month == now.month &&
          r.scheduledTime.day == now.day &&
          r.status == DoseStatus.missed;
    }).length;
    upcoming += (dosesPerDay - takenToday).clamp(0, dosesPerDay);
  }

  return TodayStats(
    total: total,
    taken: taken,
    missed: missed,
    upcoming: upcoming,
  );
});

/// Next upcoming reminder provider
final nextReminderProvider = Provider<MedicineModel?>((ref) {
  final medicines = ref.watch(todayMedicinesProvider);
  MedicineModel? next;
  DateTime? nextTime;

  for (final med in medicines) {
    final reminder = med.getNextReminderTime();
    if (reminder != null) {
      if (nextTime == null || reminder.isBefore(nextTime)) {
        nextTime = reminder;
        next = med;
      }
    }
  }
  return next;
});

/// Weekly adherence provider (last 7 days)
final weeklyAdherenceProvider = Provider<List<DayAdherence>>((ref) {
  final medicines = ref.watch(medicinesStreamProvider).value ?? [];
  final result = <DayAdherence>[];

  for (int i = 6; i >= 0; i--) {
    final day = DateTime.now().subtract(Duration(days: i));
    int dayTaken = 0;
    int dayTotal = 0;

    for (final med in medicines) {
      for (final record in med.takenHistory) {
        if (record.scheduledTime.year == day.year &&
            record.scheduledTime.month == day.month &&
            record.scheduledTime.day == day.day) {
          dayTotal++;
          if (record.status == DoseStatus.taken) dayTaken++;
        }
      }
    }

    result.add(DayAdherence(
      date: day,
      taken: dayTaken,
      total: dayTotal,
      percentage: dayTotal > 0 ? (dayTaken / dayTotal) * 100 : 0,
    ));
  }
  return result;
});

/// Filter state for medicine list
enum MedicineFilter { all, today, upcoming, completed, missed }

final medicineFilterProvider = StateProvider<MedicineFilter>((ref) => MedicineFilter.all);

/// Filtered medicines
final filteredMedicinesProvider = Provider<List<MedicineModel>>((ref) {
  final filter = ref.watch(medicineFilterProvider);
  final medicines = ref.watch(medicinesStreamProvider).value ?? [];

  switch (filter) {
    case MedicineFilter.all:
      return medicines;
    case MedicineFilter.today:
      return medicines.where((m) => m.isActiveToday).toList();
    case MedicineFilter.completed:
      return medicines.where((m) => m.getTodayStatus() == DoseStatus.taken).toList();
    case MedicineFilter.missed:
      return medicines.where((m) => m.getTodayStatus() == DoseStatus.missed).toList();
    case MedicineFilter.upcoming:
      return medicines
          .where((m) => m.isActiveToday && m.getTodayStatus() == DoseStatus.pending)
          .toList();
  }
});

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Searched medicines
final searchedMedicinesProvider = Provider<List<MedicineModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final medicines = ref.watch(filteredMedicinesProvider);
  if (query.isEmpty) return medicines;
  return medicines
      .where((m) =>
          m.name.toLowerCase().contains(query) ||
          m.dosage.toLowerCase().contains(query) ||
          m.type.displayName.toLowerCase().contains(query))
      .toList();
});

/// Medicine operations provider
class MedicineNotifier extends AsyncNotifier<void> {
  late MedicineRepository _repo;
  late NotificationService _notifService;

  @override
  Future<void> build() async {
    _repo = MedicineRepository();
    _notifService = NotificationService();
  }

  String get _userId {
    final user = ref.read(authStateProvider).value;
    if (user == null) throw Exception('Not authenticated');
    return user.uid;
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Preserve the id generated in the screen; inject the real userId
      final newMed = medicine.copyWith(userId: _userId);
      await _repo.addMedicine(_userId, newMed);
      await _notifService.scheduleNotificationsForMedicine(newMed);
    });
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Ensure userId is always correct on update too
      final updatedMed = medicine.copyWith(userId: _userId);
      await _repo.updateMedicine(_userId, updatedMed);
      await _notifService.cancelNotificationsForMedicine(updatedMed.id);
      await _notifService.scheduleNotificationsForMedicine(updatedMed);
    });
  }

  Future<void> deleteMedicine(String medicineId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteMedicine(_userId, medicineId);
      await _notifService.cancelNotificationsForMedicine(medicineId);
    });
  }

  Future<void> markDoseTaken(MedicineModel medicine) async {
    final record = DoseRecord(
      id: _uuid.v4(),
      scheduledTime: DateTime.now(),
      takenTime: DateTime.now(),
      status: DoseStatus.taken,
    );
    await _repo.markDoseTaken(_userId, medicine.id, record);
  }

  Future<void> togglePause(MedicineModel medicine) async {
    final newState = !medicine.isPaused;
    await _repo.togglePauseMedicine(_userId, medicine.id, newState);
    if (newState) {
      await _notifService.cancelNotificationsForMedicine(medicine.id);
    } else {
      await _notifService.scheduleNotificationsForMedicine(medicine);
    }
  }
}

final medicineNotifierProvider = AsyncNotifierProvider<MedicineNotifier, void>(() {
  return MedicineNotifier();
});

// Data classes for stats
class TodayStats {
  final int total;
  final int taken;
  final int missed;
  final int upcoming;

  const TodayStats({
    required this.total,
    required this.taken,
    required this.missed,
    required this.upcoming,
  });

  double get percentage => total > 0 ? (taken / total) * 100 : 0;
}

class DayAdherence {
  final DateTime date;
  final int taken;
  final int total;
  final double percentage;

  const DayAdherence({
    required this.date,
    required this.taken,
    required this.total,
    required this.percentage,
  });
}
