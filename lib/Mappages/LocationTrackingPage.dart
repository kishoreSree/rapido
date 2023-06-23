//import 'package:background_fetch/background_fetch.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Tracking {
  Position? previousPosition;
  startTracking() {
    final radius = 8.0;
    final double targetLat = 12.997023152137828;
    final double targetLong = 80.20951397716999;
    Geolocator.getPositionStream().listen((Position position) {
      previousPosition = position;
      if (previousPosition != null) {
        final distence = Geolocator.distanceBetween(
            position.latitude, position.longitude, targetLat, targetLong);

        if (distence <= radius) {
          if (previousPosition != null) {
            final prevDistance = Geolocator.distanceBetween(
                previousPosition!.latitude,
                previousPosition!.longitude,
                targetLat,
                targetLong);
            if (prevDistance > radius) {
              print("Start");
            }
          }
        } else {
          if (previousPosition != null) {
            final prevDistance = Geolocator.distanceBetween(
              previousPosition!.latitude,
              previousPosition!.longitude,
              targetLat, // Replace with your target latitude
              targetLong, // Replace with your target longitude
            );
            if (prevDistance <= radius) {
              print("Exit");
            }
          }
        }
      }
    });
  }
}

class TrackingLocation extends StatefulWidget {
  const TrackingLocation({super.key});

  @override
  State<TrackingLocation> createState() => _TrackingLocationState();
}

class _TrackingLocationState extends State<TrackingLocation> {
  StreamSubscription<Position>? positionStreamSubscribtion;
  void StartLiveTracking() {

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
