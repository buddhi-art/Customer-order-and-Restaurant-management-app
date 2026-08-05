import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff.dart';

class StaffRepository {
  final SupabaseClient _client;

  StaffRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> stream() {
    return _client.from('staff').stream(primaryKey: ['id']).order('name');
  }

  Future<void> insert(StaffMember member) async {
    await _client.from('staff').insert({
      'id': member.id,
      'name': member.name,
      'phone': member.phone,
      'role': member.role.name,
      'current_shift': member.currentShift.name,
      'hourly_wage': member.hourlyWage,
      'is_clocked_in': member.isClockedIn,
      'last_clock_in': member.lastClockIn?.toIso8601String(),
      'joined_at': member.joinedAt.toIso8601String(),
    });
  }

  Future<void> updateFields(StaffMember member) async {
    await _client
        .from('staff')
        .update({
          'name': member.name,
          'phone': member.phone,
          'role': member.role.name,
          'current_shift': member.currentShift.name,
          'hourly_wage': member.hourlyWage,
          'is_clocked_in': member.isClockedIn,
          'last_clock_in': member.lastClockIn?.toIso8601String(),
          'joined_at': member.joinedAt.toIso8601String(),
        })
        .eq('id', member.id);
  }

  Future<void> delete(String id) async {
    await _client.from('staff').delete().eq('id', id);
  }

  static StaffMember parseMember(Map<String, dynamic> row) {
    return StaffMember(
      id: row['id'] as String,
      name: row['name'] as String,
      phone: row['phone'] as String,
      role: StaffRole.values.firstWhere(
        (e) => e.name == row['role'],
        orElse: () => StaffRole.barista,
      ),
      currentShift: ShiftType.values.firstWhere(
        (e) => e.name == row['current_shift'],
        orElse: () => ShiftType.morning,
      ),
      hourlyWage: (row['hourly_wage'] as num).toDouble(),
      isClockedIn: row['is_clocked_in'] as bool,
      lastClockIn: row['last_clock_in'] != null
          ? DateTime.parse(row['last_clock_in'] as String)
          : null,
      joinedAt: DateTime.parse(row['joined_at'] as String),
    );
  }
}
