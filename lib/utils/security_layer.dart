import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityLayer {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Shared HMAC secret used to sign/verify QR table tokens.
  /// Loaded from the .env file (`QR_HMAC_SECRET`).
  ///
  /// There is deliberately NO hardcoded fallback: a known default secret would
  /// let anyone forge valid table tokens. If the secret is missing we fail loud.
  /// Startup validation (`validateEnv` in main) already guarantees it is set, so
  /// reaching the throw here means the app was misconfigured.
  static String get _qrSecret {
    final secret = dotenv.env['QR_HMAC_SECRET'];
    if (secret == null || secret.trim().isEmpty) {
      throw StateError(
        'QR_HMAC_SECRET is not configured. Refusing to sign/verify QR '
        'tokens with an insecure default.',
      );
    }
    return secret;
  }

  /// Reads cafe location and WiFi credentials from secure storage.
  /// Falls back to defaults quietly if not configured.
  static Future<_CafeCredentials> _loadCredentials() async {
    return _CafeCredentials(
      latitude:
          double.tryParse(await _storage.read(key: 'cafe_latitude') ?? '') ??
          26.648111,
      longitude:
          double.tryParse(await _storage.read(key: 'cafe_longitude') ?? '') ??
          87.978717,
      maxDistanceMeters:
          double.tryParse(
            await _storage.read(key: 'geofence_radius_meters') ?? '',
          ) ??
          25,
      approvedWifiSSID: await _storage.read(key: 'wifi_ssid') ?? '',
      approvedWifiBSSID: (await _storage.read(key: 'wifi_bssid') ?? '')
          .toLowerCase(),
    );
  }

  /// Verify a scanned QR code is a genuine `kalpa://<id>.<ts>.<hmac>` token.
  ///
  /// Rules:
  ///  * must start with `kalpa://`
  ///  * exactly 3 dot-separated parts after the prefix
  ///  * timestamp is unix-seconds and not older than 24h
  ///  * the trailing segment is HMAC-SHA256(tableId + '.' + ts, secret)
  static bool verifyQrToken(String code) {
    if (!code.startsWith('kalpa://')) return false;
    final parts = code.replaceFirst('kalpa://', '').split('.');
    if (parts.length != 3) return false;

    final tableId = parts[0];
    final timestampStr = parts[1];
    final providedHmac = parts[2];

    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return false;

    // Reject tokens older than 24 hours.
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final age = nowSeconds - timestamp;
    if (age > 86400) return false;
    // Also reject timestamps in the far future (clock-skew abuse).
    if (age < -300) return false;

    final expected = _hmacSha256('$tableId.$timestampStr', _qrSecret);
    return _constantTimeEquals(expected, providedHmac);
  }

  /// Extract the tableId from a signed `kalpa://` token, or null if invalid.
  static String? extractTableId(String code) {
    if (!verifyQrToken(code)) return null;
    return code.replaceFirst('kalpa://', '').split('.').first;
  }

  static String _hmacSha256(String message, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    return hmac.convert(bytes).toString();
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static Future<bool> verifyCheckoutSecurity() async {
    final credentials = await _loadCredentials();

    final bool isLocationValid = await _verifyLocation(credentials);
    if (!isLocationValid) return false;

    final bool isNetworkValid = await _verifyNetwork(credentials);
    if (!isNetworkValid) return false;

    return true;
  }

  static Future<bool> _verifyLocation(_CafeCredentials creds) async {
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
    final double distanceInMeters = Geolocator.distanceBetween(
      creds.latitude,
      creds.longitude,
      position.latitude,
      position.longitude,
    );

    assert(() {
      debugPrint(
        "Security Check: User is $distanceInMeters meters away from cafe.",
      );
      return true;
    }());
    return distanceInMeters <= creds.maxDistanceMeters;
  }

  static Future<bool> _verifyNetwork(_CafeCredentials creds) async {
    // If no WiFi credentials are configured, deny by default.
    // (Default-allow means a fresh install would let any network pass the
    //  security check, which is the wrong default for a payment flow.)
    if (creds.approvedWifiSSID.isEmpty && creds.approvedWifiBSSID.isEmpty) {
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
          "Security Check: Required WiFi SSID: '${creds.approvedWifiSSID}' BSSID: '${creds.approvedWifiBSSID}'",
        );
        return true;
      }());

      if (cleanWifiName == creds.approvedWifiSSID ||
          cleanWifiBSSID == creds.approvedWifiBSSID) {
        return true;
      }
      return false;
    } catch (e) {
      assert(() {
        debugPrint("Security Check Error: Network verification failed with $e");
        return true;
      }());
      return false;
    }
  }
}

class _CafeCredentials {
  final double latitude;
  final double longitude;
  final double maxDistanceMeters;
  final String approvedWifiSSID;
  final String approvedWifiBSSID;

  const _CafeCredentials({
    required this.latitude,
    required this.longitude,
    required this.maxDistanceMeters,
    required this.approvedWifiSSID,
    required this.approvedWifiBSSID,
  });
}
