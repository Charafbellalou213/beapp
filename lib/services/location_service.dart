import 'package:geolocator/geolocator.dart';

/// Recupera la posizione dell'utente in modo "tollerante": se i permessi
/// sono negati o il GPS è spento, ritorna `null` invece di lanciare un
/// errore, così la mappa può comunque mostrare marker e percorso senza
/// la posizione live.
class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {
      return null;
    }
  }
}
