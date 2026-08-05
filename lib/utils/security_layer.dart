import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../models/settings.dart';

class SecurityLayer {
  // NOTE: QR table-token signing/verification moved server-side. The HMAC
  // secret now lives only in Supabase Vault and tokens are minted/checked via
  // the generate_table_qr / redeem_table_qr RPCs (see QrService). Nothing
  // QR-related is done on the client anymore, so the shared secret is no longer
  static Future<bool> verifyCheckoutSecurity(CafeSettings settings) async {
    // Both Geofencing AND WiFi scanning (on iOS/Android) require location permissions.
    // If we don't request permissions first, NetworkInfo().getWifiName() will return null or "<unknown ssid>".
    final hasPermission = await _ensureLocationPermission();

    // STRICT REQUIREMENT: Fail immediately if location permission is denied.
    // This prevents bypassing geofencing by spoofing WiFi SSIDs while location is denied.
    if (!hasPermission) {
      assert(() {
        debugPrint(
          "Security Check: Location permission denied. Cannot verify checkout.",
        );
        return true;
      }());
      return false;
    }

    // We check location. If it passes, we return true.
    final bool isLocationValid = await _verifyLocation(settings);
    if (isLocationValid) return true;

    // We check network as a fallback only if location permission was granted.
    final bool isNetworkValid = await _verifyNetwork(settings);
    if (isNetworkValid) return true;

    return false;
  }

  static Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<bool> _verifyLocation(CafeSettings creds) async {
    // Fail closed when no cafe coordinates are configured.
    if (creds.cafeLatitude == 0 || creds.cafeLongitude == 0) {
      assert(() {
        debugPrint(
          "Security Check: No cafe coordinates configured – denying by default.",
        );
        return true;
      }());
      return false;
    }

    final Position position = await Geolocator.getCurrentPosition();
    // Reject mocked/faked positions (supported on Android).
    if (defaultTargetPlatform == TargetPlatform.android && position.isMocked) {
      assert(() {
        debugPrint("Security Check: Mocked location detected – denying.");
        return true;
      }());
      return false;
    }
    final double distanceInMeters = Geolocator.distanceBetween(
      creds.cafeLatitude,
      creds.cafeLongitude,
      position.latitude,
      position.longitude,
    );

    assert(() {
      debugPrint(
        "Security Check: User is $distanceInMeters meters away from cafe.",
      );
      return true;
    }());
    return distanceInMeters <= creds.geofenceRadiusMeters;
  }

  static Future<bool> _verifyNetwork(CafeSettings creds) async {
    // If no WiFi credentials are configured, deny by default.
    if (creds.wifiSSID.isEmpty && creds.wifiBSSID.isEmpty) {
      assert(() {
        debugPrint(
          "Security Check: No WiFi credentials configured – denying by default.",
        );
        return true;
      }());
      return false;
    }

    final info = NetworkInfo();
    try {
      final wifiName = await info.getWifiName();
      final wifiBSSID = await info.getWifiBSSID();

      // On Android, if location is denied or off, wifiName may be '<unknown ssid>'
      final cleanWifiName = wifiName?.replaceAll('"', '') ?? '';
      final cleanWifiBSSID = wifiBSSID?.toLowerCase() ?? '';

      assert(() {
        debugPrint(
          "Security Check: Current WiFi SSID: '$cleanWifiName' BSSID: '$cleanWifiBSSID'",
        );
        debugPrint(
          "Security Check: Required WiFi SSID: '${creds.wifiSSID}' BSSID: '${creds.wifiBSSID}'",
        );
        return true;
      }());

      if (cleanWifiName == '<unknown ssid>') {
        debugPrint(
          "Security Check: WiFi name is unknown. This usually means location permission is missing or location is turned off.",
        );
      }

      if (creds.wifiBSSID.isNotEmpty) {
        return cleanWifiBSSID == creds.wifiBSSID;
      }
      return cleanWifiName == creds.wifiSSID;
    } catch (e) {
      assert(() {
        debugPrint("Security Check Error: Network verification failed with $e");
        return true;
      }());
      return false;
    }
  }
}
