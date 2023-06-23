import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LatLangStorage {
  static final _storage = FlutterSecureStorage();
  static const polygonePoints = 'polygonPoints';
  static final List<LatLng> LatLngPoints = [
    LatLng(12.997091103011948, 80.20942512899637),
    LatLng(12.997073135234547, 80.20960718393326),
    LatLng(12.99697022884798, 80.20960282534361),
    LatLng(12.996985583136933, 80.20940199494362),
    LatLng(12.997091103011948, 80.20942512899637),
  ];

  static Future<void> StoreLatLng() async {
    final Pointsjson = LatLngPoints.map((point) => point.toJson()).toList();
    final pointsString = Pointsjson.toString();
    await _storage.write(key: polygonePoints, value: pointsString);
  }

  static Future getStoredLatLng() async {
    final storedpointsString = await _storage.read(key: polygonePoints);
    return storedpointsString;
    // final storedpointsList = List<String>.from(storedpointsString!.split(','));
    // final latlangPoints = <LatLng>[];
    // for (var i = 0; i < storedpointsList.length; i += 2) {
    //   final lat = double.tryParse(storedpointsList[i]);
    //   final lng = double.tryParse(storedpointsList[i + 1]);
    //   print("$lat, $lng");
    //   if (lat != null && lng != null) {
    //     latlangPoints.add(LatLng(lat, lng));
    //   } else {
    //     throw FormatException("Invalid coordinate format");
    //   }
    // }
    // print(latlangPoints);
    // return LatLngPoints;
    // final latlangPoints = storedpointsList.map((pointString) {
    //   final coordinates = pointString
    //       .split(',')
    //       .map((coordinate) => double.tryParse(coordinate.trim()));
    //   if (coordinates.length == 2 &&
    //       coordinates.every((coord) => coord != null)) {
    //     return LatLng(coordinates.first!, coordinates.last!);
    //   } else {
    //     throw FormatException("Invalid Format");
    //   }
    // }).toList();
    // print("latlng:$latlangPoints");
    // return latlangPoints;
  }
}
