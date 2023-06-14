import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class dummy extends StatefulWidget {
  const dummy({super.key});

  @override
  State<dummy> createState() => _dummyState();
}

class _dummyState extends State<dummy> {
  final LatLng _source = const LatLng(13.0827, 80.2707);
  //final LatLng _destination = const LatLng(13.0012, 80.2565);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(initialCameraPosition: CameraPosition(target: _source)),
    );
  }
}
