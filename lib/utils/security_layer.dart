import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../models/settings.dart';

class SecurityLayer {
  // NOTE: QR table-token signing/verification moved server-side. The HMAC
  // secret now lives only in Supabase Vault and tokens are minted/checked via
  // the generate_table_qr / redeem_table_qr RPCs (see QrService). Nothing
  // QR-related is done on the client anymore, so the shared secret is no longer
  // bundled in the app. Geofence + WiFi proximity checks remain below.

  static Future<bool> verifyCheckoutSecurity(CafeSettings settings) async {
    final bool isLocationValid = await _verifyLocation(settings);
    if (!isLocationValid) return false;

    final bool isNetworkValid = await _verifyNetwork(settings);
    if (!isNetworkValid) return false;

    return true;
  }

  static Future<bool> _verifyLocation(CafeSettings creds) async {
    // Fail closed when no cafe coordinates are configured, mirroring the WiFi
    // branch. A baked-in fallback location would let anyone pass the geofence.
    if (creds.cafeLatitude == 0 || creds.cafeLongitude == 0) {
      assert(() {
        debugPrint(
          "Security Check: No cafe coordinates configured – denying by default.",
        );
        return true;
      }());
      return false;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      assert(() {
        debugPrint("Security Check: Location services are disabled.");
        return true;
      }());
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        assert(() {
          debugPrint("Security Check: Location permission denied.");
          return true;
        }());
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      assert(() {
        debugPrint(
          "Security Check: Location permissions are permanently denied.",
        );
        return true;
      }());
      return false;
    }

    final Position position = await Geolocator.getCurrentPosition();
    // Reject mocked/faked positions (reliable on Android; no-op on iOS).
    if (position.isMocked) {
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
    // (Default-allow means a fresh install would let any network pass the
    //  security check, which is the wrong default for a payment flow.)
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

      // BSSID (the AP's MAC) is far harder to spoof than the SSID name. When a
      // BSSID is configured, require it to match; only fall back to the weaker
      // SSID comparison when no BSSID is set.
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
