import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rapido/Mappages/theMainMapPage.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  PermissionStatus? permissionValue;
  Future requesForLocationAccess() async {
    final PermissionStatus status = await Permission.location.request();
    print(" status is:${status}");
    if (status == PermissionStatus.granted) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => MainMap()));
    } else if (status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.denied) {
      showDialog(
          context: context,
          builder: (context) {
            return Container(
              height: 100,
              width: 200,
              child: AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    "You Denied the Location access.We Need Location Access.Please click OK to bring you app settings for giving permission for location",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Colors.amber[700]),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.amber[700]),
                      ))
                ],
              ),
            );
          });

      final PermissionStatus updatedStatus = await Permission.location.status;
      if (updatedStatus == PermissionStatus.granted) {
        print("Allowed after settings");
      } else {
        print("Still not allowed");
      }
    } else {
      print("Not Allowed");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: height - 600,
              width: width,
              child: Image.asset('android/assets/allowLocation.png'),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Location permission not enabled",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                " Sharing Location Permission helps us improve your ride",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            Text(
              "Booking and pickup experience",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[500]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: height * 0.07,
        child: Column(
          children: [
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(360, 40)),
                backgroundColor:
                    MaterialStateProperty.all<Color?>(Colors.amberAccent[700]),
              ),
              child: Text("Allow Permission"),
              onPressed: () {
                requesForLocationAccess();
              },
            ),
          ],
        ),
      ),
    );
  }
}
