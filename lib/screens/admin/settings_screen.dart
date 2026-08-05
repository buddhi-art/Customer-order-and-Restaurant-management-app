import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/settings.dart';
import '../../theme/m3_theme.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import 'admin_shell.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  late CafeSettings _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final response = await Supabase.instance.client
          .from('cafe_settings')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        if (!mounted) return;
        setState(() {
          _settings = CafeSettings(
            cafeName: response['cafe_name'] as String? ?? 'कल्प Café',
            currencySymbol: response['currency_symbol'] as String? ?? '\$',
            taxRate: (response['tax_rate'] as num?)?.toDouble() ?? 0.0,
            serviceChargeRate:
                (response['service_charge_rate'] as num?)?.toDouble() ?? 0.0,
            enableTableScanning:
                response['enable_table_scanning'] as bool? ?? true,
            enableGeofence: response['enable_geofence'] as bool? ?? false,
            wifiSSID: response['wifi_ssid'] as String? ?? '',
            wifiBSSID: response['wifi_bssid'] as String? ?? '',
            cafeLatitude:
                (response['cafe_latitude'] as num?)?.toDouble() ?? 26.648111,
            cafeLongitude:
                (response['cafe_longitude'] as num?)?.toDouble() ?? 87.978717,
            geofenceRadiusMeters:
                (response['geofence_radius_meters'] as num?)?.toDouble() ?? 25,
            openingTime: response['opening_time'] as String?,
            closingTime: response['closing_time'] as String?,
            closedDays:
                (response['closed_days'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
          );
        });
      } else {
        if (!mounted) return;
        setState(() => _settings = const CafeSettings());
      }
    } catch (e) {
      debugPrint('Failed to load settings from Supabase: $e');
      if (!mounted) return;
      setState(() => _settings = const CafeSettings());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      // Save to Supabase cafe_settings table
      await Supabase.instance.client.from('cafe_settings').upsert({
        'id': 1,
        'cafe_name': _settings.cafeName,
        'currency_symbol': _settings.currencySymbol,
        'tax_rate': _settings.taxRate,
        'service_charge_rate': _settings.serviceChargeRate,
        'enable_table_scanning': _settings.enableTableScanning,
        'enable_geofence': _settings.enableGeofence,
        'wifi_ssid': _settings.wifiSSID,
        'wifi_bssid': _settings.wifiBSSID,
        'cafe_latitude': _settings.cafeLatitude,
        'cafe_longitude': _settings.cafeLongitude,
        'geofence_radius_meters': _settings.geofenceRadiusMeters,
        'opening_time': _settings.openingTime,
        'closing_time': _settings.closingTime,
        'closed_days': _settings.closedDays,
      });

      // Sync WiFi and location to secure storage so SecurityLayer can read them
      await _storage.write(key: 'wifi_ssid', value: _settings.wifiSSID);
      await _storage.write(key: 'wifi_bssid', value: _settings.wifiBSSID);
      await _storage.write(
        key: 'cafe_latitude',
        value: _settings.cafeLatitude.toString(),
      );
      await _storage.write(
        key: 'cafe_longitude',
        value: _settings.cafeLongitude.toString(),
      );
      await _storage.write(
        key: 'geofence_radius_meters',
        value: _settings.geofenceRadiusMeters.toString(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to save settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Settings',
      selectedIndex: 11,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(48, 48, 48, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Café Settings',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      )
                      .animate()
                      .fade(duration: 400.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your café\'s configuration',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: CafeColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 50.ms),
                  const SizedBox(height: 48),

                  // General Section
                  _SettingsSection(
                    title: 'General',
                    icon: Icons.store_rounded,
                    children: [
                      _SettingsTile(
                        icon: Icons.badge_rounded,
                        title: 'Café Name',
                        subtitle: _settings.cafeName,
                        onTap: () => _editString(
                          'Café Name',
                          _settings.cafeName,
                          (v) => setState(
                            () => _settings = _settings.copyWith(cafeName: v),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.attach_money_rounded,
                        title: 'Currency Symbol',
                        subtitle: _settings.currencySymbol,
                        onTap: () => _editString(
                          'Currency Symbol',
                          _settings.currencySymbol,
                          (v) => setState(
                            () => _settings = _settings.copyWith(
                              currencySymbol: v,
                            ),
                          ),
                        ),
                      ),
                      _SwitchTile(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Table Scanning',
                        subtitle: _settings.enableTableScanning
                            ? 'Enabled'
                            : 'Disabled',
                        value: _settings.enableTableScanning,
                        onChanged: (v) => setState(
                          () => _settings = _settings.copyWith(
                            enableTableScanning: v,
                          ),
                        ),
                      ),
                      _SwitchTile(
                        icon: Icons.location_on_rounded,
                        title: 'Geofence Check-in',
                        subtitle: _settings.enableGeofence
                            ? 'Enabled'
                            : 'Disabled',
                        value: _settings.enableGeofence,
                        onChanged: (v) => setState(
                          () =>
                              _settings = _settings.copyWith(enableGeofence: v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Pricing Section
                  _SettingsSection(
                    title: 'Pricing',
                    icon: Icons.price_change_rounded,
                    children: [
                      _SettingsTile(
                        icon: Icons.percent_rounded,
                        title: 'Tax Rate',
                        subtitle:
                            '${(_settings.taxRate * 100).toStringAsFixed(1)}%',
                        onTap: () => _editNumber(
                          'Tax Rate (%)',
                          _settings.taxRate * 100,
                          (v) => setState(
                            () => _settings = _settings.copyWith(
                              taxRate: v / 100,
                            ),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.receipt_rounded,
                        title: 'Service Charge',
                        subtitle:
                            '${(_settings.serviceChargeRate * 100).toStringAsFixed(1)}%',
                        onTap: () => _editNumber(
                          'Service Charge (%)',
                          _settings.serviceChargeRate * 100,
                          (v) => setState(
                            () => _settings = _settings.copyWith(
                              serviceChargeRate: v / 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hours Section
                  _SettingsSection(
                    title: 'Operating Hours',
                    icon: Icons.schedule_rounded,
                    children: [
                      _SettingsTile(
                        icon: Icons.wb_sunny_rounded,
                        title: 'Opening Time',
                        subtitle: _settings.openingTime ?? 'Not set',
                        onTap: () => _editString(
                          'Opening Time',
                          _settings.openingTime ?? '09:00',
                          (v) => setState(
                            () =>
                                _settings = _settings.copyWith(openingTime: v),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.nightlight_round_rounded,
                        title: 'Closing Time',
                        subtitle: _settings.closingTime ?? 'Not set',
                        onTap: () => _editString(
                          'Closing Time',
                          _settings.closingTime ?? '22:00',
                          (v) => setState(
                            () =>
                                _settings = _settings.copyWith(closingTime: v),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.event_busy_rounded,
                        title: 'Closed Days',
                        subtitle: _settings.closedDays.isEmpty
                            ? 'None'
                            : _settings.closedDays.join(', '),
                        onTap: () => _editClosedDays(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Wi-Fi Section
                  _SettingsSection(
                    title: 'Wi-Fi',
                    icon: Icons.wifi_rounded,
                    children: [
                      _SettingsTile(
                        icon: Icons.wifi_rounded,
                        title: 'SSID',
                        subtitle: _settings.wifiSSID.isNotEmpty
                            ? _settings.wifiSSID
                            : 'Not set',
                        onTap: () => _editString(
                          'Wi-Fi SSID',
                          _settings.wifiSSID,
                          (v) => setState(
                            () => _settings = _settings.copyWith(wifiSSID: v),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.settings_ethernet_rounded,
                        title: 'BSSID',
                        subtitle: _settings.wifiBSSID.isNotEmpty
                            ? _settings.wifiBSSID
                            : 'Not set',
                        onTap: () => _editString(
                          'Wi-Fi BSSID',
                          _settings.wifiBSSID,
                          (v) => setState(
                            () => _settings = _settings.copyWith(wifiBSSID: v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Section
                  _SettingsSection(
                    title: 'Location',
                    icon: Icons.map_rounded,
                    children: [
                      _SettingsTile(
                        icon: Icons.pin_drop_rounded,
                        title: 'Latitude',
                        subtitle: _settings.cafeLatitude.toStringAsFixed(6),
                        onTap: () => _editNumber(
                          'Latitude',
                          _settings.cafeLatitude,
                          (v) => setState(
                            () =>
                                _settings = _settings.copyWith(cafeLatitude: v),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.pin_drop_rounded,
                        title: 'Longitude',
                        subtitle: _settings.cafeLongitude.toStringAsFixed(6),
                        onTap: () => _editNumber(
                          'Longitude',
                          _settings.cafeLongitude,
                          (v) => setState(
                            () => _settings = _settings.copyWith(
                              cafeLongitude: v,
                            ),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.radio_button_checked_rounded,
                        title: 'Geofence Radius',
                        subtitle: '${_settings.geofenceRadiusMeters.toInt()}m',
                        onTap: () => _editNumber(
                          'Geofence Radius (m)',
                          _settings.geofenceRadiusMeters,
                          (v) => setState(
                            () => _settings = _settings.copyWith(
                              geofenceRadiusMeters: v,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Save Button
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _saveSettings,
                          style: FilledButton.styleFrom(
                            backgroundColor: CafeColors.onSurface,
                            foregroundColor: CafeColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: CafeColors.surface,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save Settings',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  void _editString(
    String title,
    String current,
    ValueChanged<String> onSave,
  ) async {
    final controller = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _editNumber(
    String title,
    double current,
    ValueChanged<double> onSave,
  ) async {
    final controller = TextEditingController(text: current.toStringAsFixed(1));
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) onSave(value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _editClosedDays() {
    final allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final selected = Set<String>.from(_settings.closedDays);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Closed Days'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: allDays
                .map(
                  (day) => CheckboxListTile(
                    title: Text(day),
                    value: selected.contains(day),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          selected.add(day);
                        } else {
                          selected.remove(day);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(
                () => _settings = _settings.copyWith(
                  closedDays: selected.toList(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final double delay;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  }) : delay = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: DoubleBezelContainer(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CafeColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: CafeColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...children,
                ],
              ),
            ),
          ),
        )
        .animate()
        .fade(duration: 400.ms, delay: delay.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: CafeColors.onSurfaceVariant, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CafeColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: CafeColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: CafeColors.outline),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: CafeColors.onSurfaceVariant, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CafeColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: CafeColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: CafeColors.onSurface,
            activeTrackColor: CafeColors.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }
}
