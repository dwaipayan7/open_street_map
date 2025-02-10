import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class OpenStreetMapScreen extends StatefulWidget {
  const OpenStreetMapScreen({super.key});

  @override
  State<OpenStreetMapScreen> createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  final MapController _mapController = MapController();

  final Location _location = Location();

  final TextEditingController _locationController = TextEditingController();

  bool isLoading = true;

  LatLng? _currentLocation;
  LatLng? _destination;

  List<LatLng> _route = [];

  Future<void> _initializedLocation() async{
    if(!await _checkRequestPermission()) return;
  }

  Future<bool> _checkRequestPermission() async{
    bool serviceEnabled = await _location.serviceEnabled();
    if(!serviceEnabled){
      serviceEnabled = await _location.requestService();
      if(!serviceEnabled){
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if(permissionGranted == PermissionStatus.denied){
      permissionGranted = await _location.requestPermission();
      if(permissionGranted != PermissionStatus.granted){
        return false;
      }
    }

    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Current location not available"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("OpenStreet Map"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? LatLng(0, 0),
              initialZoom: 2,
              minZoom: 0,
              maxZoom: 100,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          _userCurrentLocation();
        },
        child: Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );
  }
}
