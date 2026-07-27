import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Enum for medicine types
enum MedicineType {
  tablet,
  capsule,
  injection,
  drops,
  syrup,
  other;

  String get displayName {
    switch (this) {
      case MedicineType.tablet: return 'Tablet';
      case MedicineType.capsule: return 'Capsule';
      case MedicineType.injection: return 'Injection';
      case MedicineType.drops: return 'Drops';
      case MedicineType.syrup: return 'Syrup';
      case MedicineType.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case MedicineType.tablet: return '💊';
      case MedicineType.capsule: return '💉';
      case MedicineType.injection: return '🩺';
      case MedicineType.drops: return '💧';
      case MedicineType.syrup: return '🥄';
      case MedicineType.other: return '🔵';
    }
  }

  Color get color {
    switch (this) {
      case MedicineType.tablet: return const Color(0xFF2F80ED);
      case MedicineType.capsule: return const Color(0xFFEB5757);
      case MedicineType.injection: return const Color(0xFFF2C94C);
      case MedicineType.drops: return const Color(0xFF27AE60);
      case MedicineType.syrup: return const Color(0xFF9B51E0);
      case MedicineType.other: return const Color(0xFF6B7280);
    }
  }
}

/// Enum for frequency
enum MedicineFrequency {
  daily,
  weekly,
  monthly,
  custom;

  String get displayName {
    switch (this) {
      case MedicineFrequency.daily: return 'Daily';
      case MedicineFrequency.weekly: return 'Weekly';
      case MedicineFrequency.monthly: return 'Monthly';
      case MedicineFrequency.custom: return 'Custom';
    }
  }
}

/// Enum for meal preference
enum MealPreference {
  beforeMeal,
  afterMeal,
  anytime;

  String get displayName {
    switch (this) {
      case MealPreference.beforeMeal: return 'Before Meal';
      case MealPreference.afterMeal: return 'After Meal';
      case MealPreference.anytime: return 'Anytime';
    }
  }
}

/// Model representing an individual dose record
class DoseRecord {
  final String id;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;

  const DoseRecord({
    required this.id,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
  });

  DoseRecord copyWith({
    String? id,
    DateTime? scheduledTime,
    DateTime? takenTime,
    DoseStatus? status,
  }) {
    return DoseRecord(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'status': status.name,
    };
  }

  factory DoseRecord.fromMap(Map<String, dynamic> map) {
    return DoseRecord(
      id: map['id'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      takenTime: map['takenTime'] != null
          ? (map['takenTime'] as Timestamp).toDate()
          : null,
      status: DoseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DoseStatus.pending,
      ),
    );
  }
}

enum DoseStatus { pending, taken, missed, skipped }

/// Core Medicine model
class MedicineModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final MedicineType type;
  final MedicineFrequency frequency;
  final List<String> times; // "HH:mm" format
  final MealPreference mealPreference;
  final DateTime startDate;
  final DateTime? endDate;
  final bool notificationEnabled;
  final bool isPaused;
  final String? imageUrl;
  final List<DoseRecord> takenHistory;
  final DateTime createdAt;
  final List<int>? weekDays; // 1=Mon to 7=Sun for weekly frequency
  final String? notes;

  const MedicineModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.type,
    required this.frequency,
    required this.times,
    required this.mealPreference,
    required this.startDate,
    this.endDate,
    required this.notificationEnabled,
    this.isPaused = false,
    this.imageUrl,
    this.takenHistory = const [],
    required this.createdAt,
    this.weekDays,
    this.notes,
  });

  MedicineModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    MedicineType? type,
    MedicineFrequency? frequency,
    List<String>? times,
    MealPreference? mealPreference,
    DateTime? startDate,
    DateTime? endDate,
    bool? notificationEnabled,
    bool? isPaused,
    String? imageUrl,
    List<DoseRecord>? takenHistory,
    DateTime? createdAt,
    List<int>? weekDays,
    String? notes,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      mealPreference: mealPreference ?? this.mealPreference,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      isPaused: isPaused ?? this.isPaused,
      imageUrl: imageUrl ?? this.imageUrl,
      takenHistory: takenHistory ?? this.takenHistory,
      createdAt: createdAt ?? this.createdAt,
      weekDays: weekDays ?? this.weekDays,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'type': type.name,
      'frequency': frequency.name,
      'times': times,
      'mealPreference': mealPreference.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'notificationEnabled': notificationEnabled,
      'isPaused': isPaused,
      'imageUrl': imageUrl,
      'takenHistory': takenHistory.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'weekDays': weekDays,
      'notes': notes,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      type: MedicineType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MedicineType.tablet,
      ),
      frequency: MedicineFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => MedicineFrequency.daily,
      ),
      times: List<String>.from(map['times'] ?? []),
      mealPreference: MealPreference.values.firstWhere(
        (e) => e.name == map['mealPreference'],
        orElse: () => MealPreference.anytime,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      notificationEnabled: map['notificationEnabled'] ?? true,
      isPaused: map['isPaused'] ?? false,
      imageUrl: map['imageUrl'],
      takenHistory: (map['takenHistory'] as List<dynamic>? ?? [])
          .map((e) => DoseRecord.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      weekDays: map['weekDays'] != null
          ? List<int>.from(map['weekDays'])
          : null,
      notes: map['notes'],
    );
  }

  /// Get today's dose status for this medicine
  DoseStatus getTodayStatus() {
    final now = DateTime.now();
    final todayRecords = takenHistory.where((r) {
      return r.scheduledTime.year == now.year &&
          r.scheduledTime.month == now.month &&
          r.scheduledTime.day == now.day;
    }).toList();

    if (todayRecords.isEmpty) return DoseStatus.pending;
    if (todayRecords.any((r) => r.status == DoseStatus.taken)) return DoseStatus.taken;
    if (todayRecords.any((r) => r.status == DoseStatus.missed)) return DoseStatus.missed;
    return DoseStatus.pending;
  }

  /// Check if medicine is active today
  bool get isActiveToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    if (today.isBefore(start)) return false;
    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (today.isAfter(end)) return false;
    }
    return true;
  }

  /// Get next upcoming reminder time
  DateTime? getNextReminderTime() {
    if (!isActiveToday || isPaused) return null;
    final now = DateTime.now();
    for (final timeStr in times) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final reminderTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (reminderTime.isAfter(now)) {
        return reminderTime;
      }
    }
    return null;
  }

  /// Adherence percentage (0-100)
  double get adherencePercentage {
    if (takenHistory.isEmpty) return 0;
    final total = takenHistory.length;
    final taken = takenHistory.where((r) => r.status == DoseStatus.taken).length;
    return (taken / total) * 100;
  }
}
