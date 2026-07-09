class CafeSettings {
  final String cafeName;
  final String currencySymbol;
  final double taxRate;
  final double serviceChargeRate;
  final bool enableTableScanning;
  final bool enableGeofence;
  final String wifiSSID;
  final String wifiBSSID;
  final double cafeLatitude;
  final double cafeLongitude;
  final double geofenceRadiusMeters;
  final String? openingTime;
  final String? closingTime;
  final List<String> closedDays;

  const CafeSettings({
    this.cafeName = 'कल्प Café',
    this.currencySymbol = '\$',
    this.taxRate = 0.0,
    this.serviceChargeRate = 0.0,
    this.enableTableScanning = true,
    this.enableGeofence = false,
    this.wifiSSID = 'Skynet-T800',
    this.wifiBSSID = '',
    this.cafeLatitude = 26.648111,
    this.cafeLongitude = 87.978717,
    this.geofenceRadiusMeters = 25,
    this.openingTime,
    this.closingTime,
    this.closedDays = const [],
  });

  CafeSettings copyWith({
    String? cafeName,
    String? currencySymbol,
    double? taxRate,
    double? serviceChargeRate,
    bool? enableTableScanning,
    bool? enableGeofence,
    String? wifiSSID,
    String? wifiBSSID,
    double? cafeLatitude,
    double? cafeLongitude,
    double? geofenceRadiusMeters,
    String? openingTime,
    String? closingTime,
    List<String>? closedDays,
  }) {
    return CafeSettings(
      cafeName: cafeName ?? this.cafeName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      taxRate: taxRate ?? this.taxRate,
      serviceChargeRate: serviceChargeRate ?? this.serviceChargeRate,
      enableTableScanning: enableTableScanning ?? this.enableTableScanning,
      enableGeofence: enableGeofence ?? this.enableGeofence,
      wifiSSID: wifiSSID ?? this.wifiSSID,
      wifiBSSID: wifiBSSID ?? this.wifiBSSID,
      cafeLatitude: cafeLatitude ?? this.cafeLatitude,
      cafeLongitude: cafeLongitude ?? this.cafeLongitude,
      geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      closedDays: closedDays ?? this.closedDays,
    );
  }
}
