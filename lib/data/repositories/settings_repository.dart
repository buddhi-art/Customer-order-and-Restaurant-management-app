import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/settings.dart';

/// All settings-related Supabase calls live here.
///
/// The provider layer must NOT import `supabase_flutter` directly; it
/// depends on this repository instead.
class SettingsRepository {
  final SupabaseClient _client;

  SettingsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Read a single row from the `cafe_settings` table.
  ///
  /// If no row exists yet (e.g. brand-new project), returns a default
  /// `CafeSettings` with a 13% tax rate (Nepal default).
  Future<CafeSettings> fetchSettings() async {
    final res = await _client
        .from('cafe_settings')
        .select()
        .eq('id', 1)
        .maybeSingle();

    if (res == null) {
      return const CafeSettings();
    }

    // tax_rate is stored as a percentage (e.g. 13.0 = 13%) in the DB.
    // `CafeSettings.taxRate` is the fractional value (0.13 = 13%).
    final rawTaxRate = (res['tax_rate'] as num?)?.toDouble();
    final taxRate = rawTaxRate == null
        ? null
        : (rawTaxRate / 100.0).clamp(0.0, 1.0);

    return CafeSettings(
      cafeName: res['cafe_name'] as String? ?? 'कल्प Café',
      currencySymbol: res['currency_symbol'] as String? ?? '\$',
      taxRate: taxRate ?? 0.0,
      serviceChargeRate:
          ((res['service_charge_rate'] as num?)?.toDouble() ?? 0.0) / 100.0,
      enableTableScanning: res['enable_table_scanning'] as bool? ?? true,
      enableGeofence: res['enable_geofence'] as bool? ?? false,
      wifiSSID: res['wifi_ssid'] as String? ?? '',
      wifiBSSID: res['wifi_bssid'] as String? ?? '',
      cafeLatitude: (res['cafe_latitude'] as num?)?.toDouble() ?? 26.648111,
      cafeLongitude: (res['cafe_longitude'] as num?)?.toDouble() ?? 87.978717,
      geofenceRadiusMeters:
          (res['geofence_radius_meters'] as num?)?.toDouble() ?? 25,
      openingTime: res['opening_time'] as String?,
      closingTime: res['closing_time'] as String?,
      closedDays: const [],
    );
  }
}
