import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/staff.dart';

class StaffNotifier extends Notifier<List<StaffMember>> {
  @override
  List<StaffMember> build() => _mockStaff;

  void addStaff(StaffMember member) {
    state = [...state, member];
  }

  void updateStaff(StaffMember member) {
    final index = state.indexWhere((s) => s.id == member.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = member;
      state = updated;
    }
  }

  void removeStaff(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void toggleClockIn(String id) {
    final index = state.indexWhere((s) => s.id == id);
    if (index < 0) return;
    final member = state[index];
    final isNowClockedIn = !member.isClockedIn;
    final updated = member.copyWith(
      isClockedIn: isNowClockedIn,
      // Record clock-in time only when actually clocking IN
      lastClockIn: isNowClockedIn ? DateTime.now() : member.lastClockIn,
    );
    final list = [...state];
    list[index] = updated;
    state = list;
  }

  List<StaffMember> get clockedIn => state.where((s) => s.isClockedIn).toList();

  List<StaffMember> get active => state.where((s) => s.isActive).toList();

  static final List<StaffMember> _mockStaff = [
    StaffMember.withDefaults(
      id: 'st-1',
      name: 'Rajesh Hamal',
      phone: '+977-9841234567',
      role: StaffRole.shiftLead,
      currentShift: ShiftType.morning,
      hourlyWage: 18.0,
      isClockedIn: true,
      joinedAt: DateTime(2025, 3, 1),
    ),
    StaffMember.withDefaults(
      id: 'st-2',
      name: 'Sita Devi',
      phone: '+977-9852345678',
      role: StaffRole.seniorBarista,
      currentShift: ShiftType.morning,
      hourlyWage: 15.0,
      isClockedIn: true,
      joinedAt: DateTime(2025, 6, 15),
    ),
    StaffMember.withDefaults(
      id: 'st-3',
      name: 'Kiran Rai',
      phone: '+977-9863456789',
      role: StaffRole.barista,
      currentShift: ShiftType.afternoon,
      hourlyWage: 12.0,
      isClockedIn: false,
      joinedAt: DateTime(2026, 1, 10),
    ),
    StaffMember.withDefaults(
      id: 'st-4',
      name: 'Maya Gurung',
      phone: '+977-9874567890',
      role: StaffRole.barista,
      currentShift: ShiftType.afternoon,
      hourlyWage: 12.0,
      isClockedIn: true,
      joinedAt: DateTime(2026, 2, 1),
    ),
    StaffMember.withDefaults(
      id: 'st-5',
      name: 'Binod Thapa',
      phone: '+977-9885678901',
      role: StaffRole.trainee,
      currentShift: ShiftType.evening,
      hourlyWage: 10.0,
      isClockedIn: false,
      joinedAt: DateTime(2026, 4, 20),
    ),
    StaffMember.withDefaults(
      id: 'st-6',
      name: 'Priya Sharma',
      phone: '+977-9896789012',
      role: StaffRole.barista,
      currentShift: ShiftType.evening,
      hourlyWage: 12.0,
      isClockedIn: true,
      joinedAt: DateTime(2026, 3, 5),
    ),
  ];
}

final staffProvider = NotifierProvider<StaffNotifier, List<StaffMember>>(
  StaffNotifier.new,
);
