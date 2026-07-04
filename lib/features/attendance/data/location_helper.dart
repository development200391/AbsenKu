import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<Position> getCurrentPosition() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw LocationException('Aktifkan layanan lokasi (GPS) terlebih dahulu.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw LocationException('Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan aplikasi.');
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
  );
}
