import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rapido/Mappages/theMainMapPage.dart';
import 'package:rapido/StartingPage.dart';
import 'package:rapido/allowLocationpage.dart';

Future<void> _firebaseMessagingBackGroundhandler(RemoteMessage message) async {
  print("Handling a background Message${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackGroundhandler);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthGate(),
  ));
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  splash() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        FlutterNativeSplash.remove();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    splash();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder(
            future: Permission.location.status,
            builder: (BuildContext context,
                AsyncSnapshot<PermissionStatus> permissionsnapshot) {
              if (permissionsnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (permissionsnapshot.data == PermissionStatus.granted) {
                return MainMap();
              } else {
                return LocationPage();
              }
            },
          );
        }
        return Rapido1_Verification();
      },
    );
  }
}
