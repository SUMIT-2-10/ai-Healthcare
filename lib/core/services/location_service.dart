import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/logger.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.w('Location services disabled');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.w('Location permission denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.w('Location permission permanently denied');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      AppLogger.e('Get location error', e);
      return null;
    }
  }

  // ─── Open Maps for hospitals ───────────────────────────────────────────────

  static Future<void> openNearestHospital() async {
    final pos = await getCurrentLocation();
    final Uri uri;

    if (pos != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/hospital/@${pos.latitude},${pos.longitude},14z',
      );
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/hospital+near+me');
    }

    await _launchUri(uri);
  }

  static Future<void> openNearestPHC() async {
    final pos = await getCurrentLocation();
    final Uri uri;

    if (pos != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/primary+health+centre/@${pos.latitude},${pos.longitude},13z',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/PHC+primary+health+centre+near+me',
      );
    }

    await _launchUri(uri);
  }

  static Future<void> callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    await _launchUri(uri);
  }

  static Future<void> _launchUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppLogger.e('Cannot launch URI: $uri');
    }
  }

  // ─── Mock nearby facilities (replace with Places API) ─────────────────────

  static List<Map<String, String>> getNearbyFacilities({bool isEmergency = false}) {
    if (isEmergency) {
      return [
        {'name': 'District Hospital', 'distance': '12 km', 'phone': '01234-56789'},
        {'name': 'Community Health Centre', 'distance': '5 km', 'phone': '01234-67890'},
        {'name': 'Private Hospital', 'distance': '8 km', 'phone': '01234-78901'},
      ];
    }
    return [
      {'name': 'Village PHC Centre', 'distance': '1.2 km', 'phone': '01234-11111'},
      {'name': 'Sub-Health Centre', 'distance': '2.8 km', 'phone': '01234-22222'},
      {'name': 'District PHC', 'distance': '7.5 km', 'phone': '01234-33333'},
    ];
  }
}
