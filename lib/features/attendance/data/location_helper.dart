import 'package:geolocator/geolocator.dart';

/// The device's location service (GPS) is turned off. Client-side and
/// translatable — see [AppLocalizations.locationServiceDisabled].
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

/// The app was denied location permission. Client-side and translatable —
/// see [AppLocalizations.locationPermissionDenied].
class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

Future<Position> getCurrentPosition() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const LocationServiceDisabledException();
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw const LocationPermissionDeniedException();
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
  );
}
