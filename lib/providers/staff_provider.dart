import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/staff.dart';
import '../data/repositories/staff_repository.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) => StaffRepository());

class StaffNotifier extends Notifier<List<StaffMember>> {
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  late final StaffRepository _repo;

  @override
  List<StaffMember> build() {
    _repo = ref.read(staffRepositoryProvider);
    _listenToStaff();
    ref.onDispose(() => _subscription?.cancel());
    return const [];
  }

  void _listenToStaff() {
    try {
      _subscription = _repo.stream().listen(
        (List<Map<String, dynamic>> data) {
          final loaded = data.map<StaffMember>(StaffRepository.parseMember).toList();
          state = loaded;
        },
        onError: (error) {
          debugPrint('Staff stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Staff stream not available: $e');
    }
  }

  Future<void> addStaff(StaffMember member) async {
    try {
      await _repo.insert(member);
    } catch (e) {
      debugPrint('Failed to add staff: $e');
      rethrow;
    }
  }

  Future<void> updateStaff(StaffMember member) async {
    try {
      await _repo.updateFields(member);
    } catch (e) {
      debugPrint('Failed to update staff: $e');
      rethrow;
    }
  }

  Future<void> removeStaff(String id) async {
    try {
      await _repo.delete(id);
    } catch (e) {
      debugPrint('Failed to remove staff: $e');
      rethrow;
    }
  }

  Future<void> toggleClockIn(String id) async {
    final index = state.indexWhere((s) => s.id == id);
    if (index < 0) return;
    final member = state[index];
    final isNowClockedIn = !member.isClockedIn;
    final updated = member.copyWith(
      isClockedIn: isNowClockedIn,
      lastClockIn: isNowClockedIn ? DateTime.now() : member.lastClockIn,
    );
    try {
      await _repo.updateFields(updated);
    } catch (e) {
      debugPrint('Failed to toggle clock in: $e');
      rethrow;
    }
  }

  List<StaffMember> get clockedIn => state.where((s) => s.isClockedIn).toList();
  List<StaffMember> get active => state.where((s) => s.isActive).toList();
}

final staffProvider = NotifierProvider<StaffNotifier, List<StaffMember>>(
  StaffNotifier.new,
);
