import 'package:flutter/material.dart';

enum StaffRole { barista, seniorBarista, shiftLead, manager, trainee }

extension StaffRoleExt on StaffRole {
  String get label {
    switch (this) {
      case StaffRole.barista:
        return 'Barista';
      case StaffRole.seniorBarista:
        return 'Senior Barista';
      case StaffRole.shiftLead:
        return 'Shift Lead';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.trainee:
        return 'Trainee';
    }
  }

  String get shortLabel {
    switch (this) {
      case StaffRole.barista:
        return 'BST';
      case StaffRole.seniorBarista:
        return 'SR';
      case StaffRole.shiftLead:
        return 'SL';
      case StaffRole.manager:
        return 'MGR';
      case StaffRole.trainee:
        return 'TRN';
    }
  }
}

enum ShiftType { morning, afternoon, evening }

extension ShiftTypeExt on ShiftType {
  String get label {
    switch (this) {
      case ShiftType.morning:
        return 'Morning (6-2)';
      case ShiftType.afternoon:
        return 'Afternoon (10-6)';
      case ShiftType.evening:
        return 'Evening (2-10)';
    }
  }

  String get shortLabel {
    switch (this) {
      case ShiftType.morning:
        return 'AM';
      case ShiftType.afternoon:
        return 'MID';
      case ShiftType.evening:
        return 'PM';
    }
  }

  TimeOfDay get startTime {
    switch (this) {
      case ShiftType.morning:
        return const TimeOfDay(hour: 6, minute: 0);
      case ShiftType.afternoon:
        return const TimeOfDay(hour: 10, minute: 0);
      case ShiftType.evening:
        return const TimeOfDay(hour: 14, minute: 0);
    }
  }

  TimeOfDay get endTime {
    switch (this) {
      case ShiftType.morning:
        return const TimeOfDay(hour: 14, minute: 0);
      case ShiftType.afternoon:
        return const TimeOfDay(hour: 18, minute: 0);
      case ShiftType.evening:
        return const TimeOfDay(hour: 22, minute: 0);
    }
  }
}

class StaffMember {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final StaffRole role;
  final bool isActive;
  final DateTime? lastClockIn;
  final bool isClockedIn;
  final ShiftType currentShift;
  final double hourlyWage;
  final DateTime joinedAt;
  final String? avatarUrl;

  const StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.role = StaffRole.barista,
    this.isActive = true,
    this.lastClockIn,
    this.isClockedIn = false,
    this.currentShift = ShiftType.morning,
    this.hourlyWage = 12.0,
    required this.joinedAt,
    this.avatarUrl,
  });

  StaffMember.withDefaults({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.role = StaffRole.barista,
    this.isActive = true,
    this.lastClockIn,
    this.isClockedIn = false,
    this.currentShift = ShiftType.morning,
    this.hourlyWage = 12.0,
    DateTime? joinedAt,
    this.avatarUrl,
  }) : joinedAt = joinedAt ?? DateTime.now();

  StaffMember copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    StaffRole? role,
    bool? isActive,
    DateTime? lastClockIn,
    bool? isClockedIn,
    ShiftType? currentShift,
    double? hourlyWage,
    DateTime? joinedAt,
    String? avatarUrl,
  }) {
    return StaffMember.withDefaults(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastClockIn: lastClockIn ?? this.lastClockIn,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      currentShift: currentShift ?? this.currentShift,
      hourlyWage: hourlyWage ?? this.hourlyWage,
      joinedAt: joinedAt ?? this.joinedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'role': role.name,
    'is_active': isActive,
    'last_clock_in': lastClockIn?.toIso8601String(),
    'is_clocked_in': isClockedIn,
    'current_shift': currentShift.name,
    'hourly_wage': hourlyWage,
    'joined_at': joinedAt.toIso8601String(),
    'avatar_url': avatarUrl,
  };

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      StaffMember.withDefaults(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String?,
        role: StaffRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => StaffRole.barista,
        ),
        isActive: json['is_active'] as bool? ?? true,
        lastClockIn: json['last_clock_in'] != null
            ? DateTime.tryParse(json['last_clock_in'] as String)
            : null,
        isClockedIn: json['is_clocked_in'] as bool? ?? false,
        currentShift: ShiftType.values.firstWhere(
          (s) => s.name == json['current_shift'],
          orElse: () => ShiftType.morning,
        ),
        hourlyWage: (json['hourly_wage'] as num?)?.toDouble() ?? 12.0,
        joinedAt:
            DateTime.tryParse(json['joined_at'] as String? ?? '') ??
            DateTime.now(),
        avatarUrl: json['avatar_url'] as String?,
      );
}
