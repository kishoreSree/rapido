import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:rapido/Mappages/historyPage.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late GoogleMapController mapController;
  //GlobalKey<GoogleMapState> mapkey = GlobalKey<GoogleMapState>();

  TextEditingController pickupLocController = TextEditingController();
  // final LatLng _source = const LatLng(13.0827, 80.2707);
  // final LatLng _destination = const LatLng(13.0012, 80.2565);
  String? _mapString;
  List<LatLng> coordinates = [];
  double? CRlangtitude;
  double? CRlatitude;
  double? newLat;
  double? newlng;
  String? newAddress;
  bool? forRadius;
  LatLng? newLatlang;
  Circle? circle;
  bool? currentLoc;
  double? newlat1;
  double? newlng1;

  BitmapDescriptor markericon1 = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markericon2 = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markericon3 = BitmapDescriptor.defaultMarker;
  ValueNotifier<bool> forRadiues = ValueNotifier<bool>(false);
  LatLng? currentLocation;
  ValueNotifier<LatLng> circlepositonValues =
      ValueNotifier<LatLng>(LatLng(0, 0));
  List<Marker> markersWithinRadius = [];
  List<Marker> markersWithoutRadius = [];
  ValueNotifier<double?> newLatNotifier = ValueNotifier<double?>(null);
  ValueNotifier<double?> newLngNotifier = ValueNotifier<double?>(null);

  void _OnMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapString);
  }

  void initializeCirclePosition() {
    circlepositonValues.value = LatLng(CRlatitude!, CRlangtitude!);
  }

  Future<void> locationNotify() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      print("granded");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainMap()));
    } else {
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => MainMap()));
      Navigator.pop(context);
    }
  }

  Future<Uint8List?> ControllingIcons(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ByteData? byteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      return byteData.buffer.asUint8List();
    } else {
      return null;
    }
  }

  void calllingCustomicons(bool Nlocation, bool auto, bool bike) async {
    Uint8List? markericon11 = await ControllingIcons(
        Nlocation
            ? "android/assets/place.png"
            : auto
                ? "android/assets/rickshaw .png"
                : bike
                    ? "android/assets/electric.png"
                    : "",
        Nlocation
            ? 130
            : auto
                ? 100
                : bike
                    ? 100
                    : 0);
    if (markericon11 != null) {
      setState(() {
        if (Nlocation == true) {
          markericon1 = BitmapDescriptor.fromBytes(markericon11);
        }
        if (auto == true) {
          markericon2 = BitmapDescriptor.fromBytes(markericon11);
        }
        if (bike == true) {
          markericon3 = BitmapDescriptor.fromBytes(markericon11);
        }
      });
    }
  }

  markerDragEndAdress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        // newPosition.latitude,
        // newPosition.longitude
        CRlatitude!,
        CRlangtitude!);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String Address = placemark.thoroughfare ?? '';
      Address += (placemark.street != null) ? ",${placemark.street}" : "";
      Address +=
          (placemark.subLocality != null) ? ",${placemark.subLocality}" : "";
      Address += (placemark.locality != null) ? ",${placemark.locality}" : "";
      Address += (placemark.administrativeArea != null)
          ? ",${placemark.administrativeArea}"
          : "";
      Address +=
          (placemark.postalCode != null) ? ",${placemark.postalCode}" : "";
      Address += (placemark.country != null) ? ",${placemark.country}" : "";

      newAddress = Address;
      print("address:$newAddress");
      pickupLocController.text = newAddress!;
    } else {
      newAddress = "Unknown";
    }
  }

  Future<bool> getCurrentlocation() async {
    bool islocationEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (islocationEnabled) {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);
      double lat = position.latitude;
      double lng = position.longitude;
      print("lat:$lat");
      print("lng:$lng");
      setState(() {
        CRlangtitude = lng;
        CRlatitude = lat;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isLocationenabled() async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    return serviceEnabled;
  }

  // Future<PermissionStatus> isLocationenabled1() async {
  //   loc.Location location = loc.Location();
  //   PermissionStatus serviceEnabled = await location.requestPermission();
  //   return serviceEnabled;
  // }

  @override
  void initState() {
    getCurrentlocation();
    calllingCustomicons(true, false, false);
    calllingCustomicons(false, true, false);
    calllingCustomicons(false, false, true);

    rootBundle.loadString('android/assets/silver_map.txt').then((string) {
      _mapString = string;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
          future: isLocationenabled(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              );
            }
            if (snapshot.hasData && snapshot.data != null && !snapshot.data!) {
              return Center(
                  child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: 350,
                child: Card(
                  elevation: 6,
                  color: Colors.amber[400],
                  child: Column(
                    children: [
                      Image.asset("android/assets/Around the world-pana.png"),
                      const Text(
                        "Oops!.You did not give access for location service",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Turn on location service to continue",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                                Colors.deepOrange),
                          ),
                          onPressed: () async {
                            locationNotify();
                            // PermissionStatus status =
                            //     await Permission.location.request();
                            // if (status.isGranted) {
                            //   print("granded");
                            //   Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) => MainMap()));
                            // } else {
                            //   // Navigator.pushReplacement(
                            //   //     context,
                            //   //     MaterialPageRoute(
                            //   //         builder: (context) => MainMap()));
                            //   Navigator.pop(context);
                            // }
                          },
                          child: Text("Ok")),
                    ],
                  ),
                ),
              ));
            } else {
              return SafeArea(
                child: CRlatitude != null
                    ? Column(
                        children: [
                          Flexible(
                            child: Stack(
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(microseconds: 500),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: ValueListenableBuilder(
                                      valueListenable: forRadiues,
                                      builder: (BuildContext context,
                                          bool forRadius, Widget? child) {
                                        return GoogleMap(
                                          key: PageStorageKey('MapPageKey'),
                                          onMapCreated: _OnMapCreated,
                                          initialCameraPosition: CameraPosition(
                                              target: LatLng(
                                                  newLat ?? CRlatitude!,
                                                  newlng ?? CRlangtitude!),
                                              //_source,
                                              zoom: 14.0),
                                          markers: Set<Marker>.from([
                                            // Marker(
                                            //     markerId:
                                            //         const MarkerId("Currentlocation"),
                                            //     position: _source,
                                            //     draggable: true,
                                            //     icon: markericon1),
                                            Marker(
                                                markerId:
                                                    const MarkerId("Auto-1"),
                                                position: newLat == null
                                                    ? LatLng(
                                                        CRlatitude! + 0.01000,
                                                        CRlangtitude! +
                                                            0.000050)
                                                    : LatLng(newLat! + 0.00500,
                                                        newlng! + 0.000050),
                                                icon: markericon2),
                                            Marker(
                                                markerId:
                                                    const MarkerId("Auto-2"),
                                                position: newLat == null
                                                    ? LatLng(
                                                        CRlatitude! + 0.00190,
                                                        CRlangtitude! +
                                                            0.000150)
                                                    : LatLng(newLat! + 0.00180,
                                                        newlng! + 0.000150),
                                                icon: markericon2),
                                            Marker(
                                                markerId:
                                                    const MarkerId("Auto-3"),
                                                position: LatLng(
                                                    CRlatitude! - 0.00500,
                                                    CRlangtitude! + 0.000050),
                                                icon: markericon2),

                                            Marker(
                                                markerId:
                                                    const MarkerId("Auto-5"),
                                                position: newLat == null
                                                    ? LatLng(
                                                        CRlatitude! + 0.000250,
                                                        CRlangtitude! +
                                                            0.004400)
                                                    : LatLng(newLat! + 0.00250,
                                                        newlng! + 0.004400),
                                                icon: markericon2),
                                            Marker(
                                                markerId:
                                                    const MarkerId("Auto-6"),
                                                position: LatLng(
                                                    CRlatitude! + 0.002250,
                                                    CRlangtitude! + 0.004400),
                                                icon: markericon2),
                                            Marker(
                                                markerId:
                                                    const MarkerId("bike-1"),
                                                position:
                                                    LatLng(12.9975, 80.2006),
                                                icon: markericon3),
                                            Marker(
                                                markerId:
                                                    const MarkerId("bike-2"),
                                                position:
                                                    LatLng(12.9275, 80.2206),
                                                icon: markericon3),
                                            Marker(
                                                markerId:
                                                    const MarkerId("bike"),
                                                position:
                                                    LatLng(12.9899, 80.2100),
                                                icon: markericon3),
                                            Marker(
                                              markerId:
                                                  MarkerId("CurrentLocation"),
                                              position: LatLng(
                                                newLat ?? CRlatitude!,
                                                newlng ?? CRlangtitude!,
                                              ),
                                              icon: markericon1,
                                              draggable: true,
                                              onDragStart: (value) {
                                                forRadiues.value = false;
                                              },
                                              onDragEnd: (newPosition) async {
                                                print(newPosition.latitude);
                                                print(newPosition.longitude);

                                                newLat = newPosition.latitude;
                                                newlng = newPosition.longitude;
                                                newlat1 = newLat;
                                                newlng1 = newlng1;
                                                forRadius = true;
                                                forRadiues.value = true;
                                                newLatNotifier.value =
                                                    newPosition.latitude;
                                                newLngNotifier.value =
                                                    newPosition.longitude;

                                                List<Placemark> placemarks =
                                                    await placemarkFromCoordinates(
                                                        newLat!, newlng!);
                                                if (placemarks.isNotEmpty) {
                                                  Placemark placemark =
                                                      placemarks.first;
                                                  String Address =
                                                      placemark.thoroughfare ??
                                                          '';
                                                  Address += (placemark
                                                              .street !=
                                                          null)
                                                      ? ",${placemark.street}"
                                                      : "";
                                                  Address += (placemark
                                                              .subLocality !=
                                                          null)
                                                      ? ",${placemark.subLocality}"
                                                      : "";
                                                  Address += (placemark
                                                              .locality !=
                                                          null)
                                                      ? ",${placemark.locality}"
                                                      : "";
                                                  Address += (placemark
                                                              .administrativeArea !=
                                                          null)
                                                      ? ",${placemark.administrativeArea}"
                                                      : "";
                                                  Address += (placemark
                                                              .postalCode !=
                                                          null)
                                                      ? ",${placemark.postalCode}"
                                                      : "";
                                                  Address += (placemark
                                                              .country !=
                                                          null)
                                                      ? ",${placemark.country}"
                                                      : "";

                                                  newAddress = Address;
                                                  print("address:$newAddress");
                                                  pickupLocController.text =
                                                      newAddress!;
                                                } else {
                                                  newAddress = "Unknown";
                                                }
                                              },
                                            ),
                                          ].where((marker) {
                                            final distance =
                                                geo.Geolocator.distanceBetween(
                                                    marker.position.latitude,
                                                    marker.position.longitude,
                                                    newLat ?? CRlatitude!,
                                                    newlng ?? CRlangtitude!);
                                            bool iswithinradius =
                                                distance <= 800;
                                            if (iswithinradius) {
                                              markersWithinRadius.add(marker);
                                              print(
                                                  "MarkerId for In:${marker.markerId}");
                                            } else {
                                              markersWithoutRadius.add(marker);
                                              print(
                                                  "MarkerId for Out:${marker.markerId}");
                                            }
                                            return iswithinradius;
                                          })),
                                          circles: {
                                            Circle(
                                              circleId: CircleId("Circle"),
                                              center: forRadiues == true
                                                  ? LatLng(CRlatitude!,
                                                      CRlangtitude!)
                                                  : LatLng(
                                                      newLat ?? CRlatitude!,
                                                      newlng ?? CRlangtitude!),
                                              radius: 800,
                                              fillColor: Colors.blue.shade100
                                                  .withOpacity(0.5),
                                              strokeColor: Colors.blue.shade100
                                                  .withOpacity(0.1),
                                              strokeWidth: 5,
                                            ),

                                            // ValueListenableBuilder<double?>(
                                            //   valueListenable: newLatNotifier,
                                            //   builder: (BuildContext context,
                                            //       double? newlng,
                                            //       Widget? child) {
                                            //     return ValueListenableBuilder<
                                            //             double?>(
                                            //         valueListenable:
                                            //             newLngNotifier,
                                            //         builder:
                                            //             (BuildContext context,
                                            //                 double? newlat,
                                            //                 Widget? child) {
                                            //           if (newLat != null &&
                                            //               newlng != null) {
                                            //             return Circle(
                                            //                 circleId: CircleId(
                                            //                     "NewLatRadius"));
                                            //           } else {
                                            //             return const SizedBox();
                                            //           }
                                            //         });
                                            //   },
                                            // ),
                                            // if (forRadius == true)
                                            //   Circle(
                                            //     circleId:
                                            //         CircleId("radiusNewlat"),
                                            //     center: LatLng(
                                            //       newlat1 ?? CRlatitude!,
                                            //       newlng1 ?? CRlangtitude!,
                                            //     ),
                                            //     radius: 800,
                                            //     fillColor: Colors.blue.shade100
                                            //         .withOpacity(0.5),
                                            //     strokeColor: Colors
                                            //         .blue.shade100
                                            //         .withOpacity(0.1),
                                            //     strokeWidth: 5,
                                            //   ),

                                            // if (newLat == null &&
                                            //     newlng == null)
                                            //   Circle(
                                            //     circleId: CircleId(
                                            //         "CurrentLocationCircle"),
                                            //     center: LatLng(
                                            //         CRlatitude!, CRlangtitude!),
                                            //     radius: 800,
                                            //     fillColor: Colors.blue.shade100
                                            //         .withOpacity(0.5),
                                            //     strokeColor: Colors
                                            //         .blue.shade100
                                            //         .withOpacity(0.1),
                                            //     strokeWidth: 5,
                                            //   )
                                          },
                                          zoomControlsEnabled: false,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                    top: 23,
                                    left: 8,
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                width: 0,
                                                color: Colors.transparent)),
                                        child: Icon(Icons.menu),
                                      ),
                                    )),
                                Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                        height: 50,
                                        width: 50,
                                        child: Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: IconButton(
                                              onPressed: () async {
                                                currentLocation = LatLng(
                                                    CRlatitude!, CRlangtitude!);
                                                currentLoc = true;
                                                print("Curr:$currentLoc");

                                                markerDragEndAdress();

                                                // currentLocation = LatLng(
                                                //     CRlatitude!, CRlangtitude!);

                                                // mapController.animateCamera(
                                                //     CameraUpdate.newLatLng(
                                                //         currentLocation!));
                                              },
                                              icon: const Icon(
                                                Icons.gps_fixed,
                                                color: Colors.black,
                                              )),
                                        ))),
                                Positioned(
                                  top: 20,
                                  left: 55,
                                  child: Stack(
                                    children: [
                                      Card(
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: TextField(
                                            controller: pickupLocController,
                                            cursorColor:
                                                Colors.amberAccent[700],
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Your Current Location',
                                                hintStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                                contentPadding:
                                                    EdgeInsets
                                                        .fromLTRB(35, 12, 12,
                                                            12),
                                                fillColor: Colors.white,
                                                filled: true,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide(
                                                                color: Colors
                                                                    .white,
                                                                width: 0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.favorite_border,
                                                  ),
                                                  onPressed: () {},
                                                )),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  slidePage(
                                                      page: SearchHistories(
                                                    Searchhint:
                                                        " Enter your pickup location",
                                                  )));
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 18,
                                        left: 18,
                                        child: Icon(
                                          Icons.circle,
                                          size: 13,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 350,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 15, 12, 0),
                                  child: Stack(
                                    children: [
                                      Card(
                                        elevation: 6,
                                        color: Colors.blueGrey[50],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Container(
                                          height: 40,
                                          child: TextField(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    slidePage(
                                                        page: SearchHistories(
                                                      Searchhint:
                                                          "Enter your drop Location",
                                                    )));
                                              },
                                              readOnly: true,
                                              cursorColor:
                                                  Colors.amberAccent[700],
                                              decoration: InputDecoration(
                                                hintText: 'Enter Drop Location',
                                                hintStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        35, 12, 12, 12),
                                                fillColor: Colors.blueGrey[50],
                                                filled: true,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.white,
                                                            width: 0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                              )),
                                        ),
                                      ),
                                      Positioned(
                                        top: 18,
                                        left: 12,
                                        child: Icon(
                                          Icons.circle,
                                          size: 13,
                                          color: const Color.fromARGB(
                                              255, 223, 16, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                    child: Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Container(
                                    height: 200,
                                    width: 300,
                                    child: Image.asset(
                                        "android/assets/Order ride-rafiki.png"),
                                  ),
                                )),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                    child: Text(
                                  "Book ride now by searching your drop location",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                            ),
                            Image.asset("android/assets/gifAnime2.gif"),
                            Text(
                              "Loading.....",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
              );
            }
          }),
    );
  }

  void updateLocation() {
    newLat = null;
    newlng = null;
    markerDragEndAdress();
  }
}

class slidePage extends PageRouteBuilder {
  final Widget page;
  slidePage({required this.page})
      : super(
            pageBuilder: (_, __, ___) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
              final curveTween = CurveTween(curve: Curves.easeInOut);
              return SlideTransition(
                position: animation.drive(curveTween).drive(tween),
                child: child,
              );
            });
}
