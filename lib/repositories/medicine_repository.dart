import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

/// Firestore medicine repository
class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _medicinesRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('medicines');

  /// Real-time stream of medicines for a user
  Stream<List<MedicineModel>> watchMedicines(String userId) {
    return _medicinesRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get all medicines once
  Future<List<MedicineModel>> getMedicines(String userId) async {
    final snapshot = await _medicinesRef(userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => MedicineModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get a single medicine
  Future<MedicineModel?> getMedicine(String userId, String medicineId) async {
    final doc = await _medicinesRef(userId).doc(medicineId).get();
    if (!doc.exists) return null;
    return MedicineModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  /// Add a new medicine
  Future<MedicineModel> addMedicine(String userId, MedicineModel medicine) async {
    final docRef = _medicinesRef(userId).doc(medicine.id);
    final updated = medicine.copyWith(userId: userId);
    await docRef.set(updated.toMap());
    return updated;
  }

  /// Update medicine
  Future<void> updateMedicine(String userId, MedicineModel medicine) async {
    await _medicinesRef(userId).doc(medicine.id).update(medicine.toMap());
  }

  /// Delete medicine
  Future<void> deleteMedicine(String userId, String medicineId) async {
    await _medicinesRef(userId).doc(medicineId).delete();
  }

  /// Mark dose as taken
  Future<void> markDoseTaken(String userId, String medicineId, DoseRecord record) async {
    await _medicinesRef(userId).doc(medicineId).update({
      'takenHistory': FieldValue.arrayUnion([record.toMap()])
    });
  }

  /// Toggle pause/resume for medicine
  Future<void> togglePauseMedicine(String userId, String medicineId, bool isPaused) async {
    await _medicinesRef(userId).doc(medicineId).update({'isPaused': isPaused});
  }

  /// Get today's active medicines
  Future<List<MedicineModel>> getTodayMedicines(String userId) async {
    final all = await getMedicines(userId);
    return all.where((m) => m.isActiveToday).toList();
  }

  /// Get medicines by date range for history
  Future<List<MedicineModel>> getMedicinesForHistory(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    final all = await getMedicines(userId);
    return all.where((m) {
      final hasHistoryInRange = m.takenHistory.any((r) =>
          r.scheduledTime.isAfter(from) && r.scheduledTime.isBefore(to));
      return hasHistoryInRange;
    }).toList();
  }
}
