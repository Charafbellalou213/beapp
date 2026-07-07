import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _locationService = LocationService();
  final _fallbackRouteService = RouteService();

  GoogleMapController? _mapController;
  Position? _userPosition;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _userPosition = position;
      _isLocating = false;
    });

    if (position != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final startLat = _userPosition?.latitude ?? AppConstants.padovaCenterLat;
    final startLng = _userPosition?.longitude ?? AppConstants.padovaCenterLng;

    // Se l'utente ha già scelto un percorso nella Route screen lo mostriamo;
    // altrimenti calcoliamo un percorso "lungo" di default solo per avere
    // sempre qualcosa da disegnare in mappa.
    final route = appState.currentRoute ??
        (appState.places.isEmpty
            ? null
            : _fallbackRouteService.buildRoute(
                availablePlaces: appState.places,
                length: RouteLength.long,
                startLatitude: startLat,
                startLongitude: startLng,
              ));

    final markers = <Marker>{
      for (final place in appState.places)
        Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            place.isVisited ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(title: place.name, snippet: '+${place.points} punti'),
        ),
      for (final restaurant in appState.restaurants)
        Marker(
          markerId: MarkerId('restaurant_${restaurant.id}'),
          position: LatLng(restaurant.latitude, restaurant.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: restaurant.name, snippet: restaurant.priceRange),
        ),
      if (_userPosition != null)
        Marker(
          markerId: const MarkerId('user_position'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Sei qui'),
        ),
    };

    final polylines = <Polyline>{
      if (route != null && route.places.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('percorso_consigliato'),
          color: Theme.of(context).colorScheme.primary,
          width: 4,
          points: [
            LatLng(startLat, startLng),
            for (final place in route.places) LatLng(place.latitude, place.longitude),
          ],
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Mappa')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(startLat, startLng),
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: markers,
            polylines: polylines,
          ),
          if (_isLocating)
            const _InfoBanner(text: 'Ricerca della tua posizione...'),
          if (!_isLocating && _userPosition == null)
            const _InfoBanner(
              text: 'Posizione non disponibile: la mappa mostra il centro di Padova.',
            ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    );
  }
}
