import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rapido/Rapido_methods.dart';

import 'OTPpage.dart';
import 'libEmail.dart';

class Rapido1_Verification extends StatefulWidget {
  const Rapido1_Verification({super.key});

  @override
  State<Rapido1_Verification> createState() => _Rapido1_VerificationState();
}

class _Rapido1_VerificationState extends State<Rapido1_Verification> {
  OTPVerification otpVerification = OTPVerification();
  // FirebaseMessaging _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? Token = "";
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  bool autoPlayAnimation = false;
  TextEditingController PhoneNumbercontroller = TextEditingController();
  bool Circle = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isEmailValid = false;
  int dotindex = 0;
  //static String emailForNextpage = "";
  TextEditingController otpcontroller = TextEditingController();
  @override
  void initState() {
    requestPermission();
    initInfo();
    super.initState();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User Granted Provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void GetToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        Token = token;
        print("Token:${Token}");
      });
    });
  }

  add() async {
    try {
      await FirebaseFirestore.instance
          .collection("FirstTrail")
          .add({'name': 'kishore'});
      print("ok");
    } catch (e) {
      print(e.toString());
    }
  }

  void initInfo() async {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var IosInitialize = const DarwinInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: IosInitialize);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      try {
        if (response.payload != null && response.payload!.isNotEmpty) {
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => FormPage()));
        } else {}
      } catch (e) {}
      return;
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("...........OnMessage.............");
      print(
          "onMessage:${message.notification?.title}/${message.notification?.body}}");
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContent: true,
      );
      AndroidNotificationDetails androidchannelPlatformSpecifies =
          AndroidNotificationDetails(
        'PushNote',
        'PushNote',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );
      // var isoPlatformspecifies=const IOSNoticationDetails();
      NotificationDetails PlatformChannelSpecifies =
          NotificationDetails(android: androidchannelPlatformSpecifies);

      await _flutterLocalNotificationsPlugin.show(
          0,
          message.notification?.title,
          message.notification?.body,
          PlatformChannelSpecifies,
          payload: message.data['body']);
    });
  }

  // Future<void> _showNotification(String title, String body) async {
  //   var androidChannelSpecifics = AndroidNotificationDetails(
  //     'channelId',
  //     'channelName',
  //     channelDescription: 'channelDescription',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //   );
  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidChannelSpecifics,
  //   );
  //   await _flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     body,
  //     platformChannelSpecifics,
  //   );
  // }

  Widget slider(String asset, bool first, String topText1, String topText2) {
    double heights = MediaQuery.of(context).size.height - 500;
    double widths = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          child: Image.asset(
            '${asset}',
            fit: BoxFit.cover,
            height: heights,
            width: widths,
          ),
        ),
        Positioned(
            child: Padding(
          padding: EdgeInsets.only(left: 14),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "$topText1",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "$topText2",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        )),
        Positioned(
          bottom: 10,
          right: 10,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Container(
                  height: 8,
                  width: 10,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Circle ? Colors.black : Colors.transparent,
                      border: Border.all(width: 1)),
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  height: 8,
                  width: 10,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Circle ? Colors.transparent : Colors.black,
                      border: Border.all(width: 1)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          child: Padding(
            padding: EdgeInsets.fromLTRB(widths * 0.9, 0, 0, 0),
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.help_outline_outlined,
                  size: 20,
                )),
          ),
          //  ),
        ),
      ],
    );
  }

  Widget texts(String text, bool firstText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 0, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "${text}",
          style: firstText
              ? TextStyle(fontWeight: FontWeight.w700, fontSize: 16)
              : TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.grey[700]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // double heights = MediaQuery.of(context).size.height ;
    //double widths = MediaQuery.of(context).size.width ;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            CarouselSlider(
                items: [
                  slider('android/assets/driver.png', true, "Safety all along",
                      "2 Cr+ safe rides beating the traffic"),
                  slider('android/assets/bikeTaxi.png', false,
                      "Convenient Rides", "Across 100+ cities in India"),
                ],
                options: CarouselOptions(
                  autoPlay: !autoPlayAnimation,
                  autoPlayInterval: Duration(seconds: 2),
                  //autoPlayAnimationDuration: Duration(seconds: 0),
                  viewportFraction: 1,
                  aspectRatio: 21 / 17,
                  onPageChanged: (index, reason) {
                    setState(() {
                      autoPlayAnimation = true;
                      Circle = false;
                      dotindex = index;
                    });
                    if (index == 0) {
                      setState(() {
                        Circle = true;
                      });
                    }
                  },
                )),
            texts("Let's get started", true),
            texts("Verify your account using OTP", false),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 15, 10, 0),
              child: Form(
                key: _formkey,
                child: Container(
                  // height: MediaQuery.of(context).size.height - 600,
                  height: 70,
                  width: MediaQuery.of(context).size.width - 25,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 16,
                          left: 10,
                          child: Text(
                            "+91 ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          )),
                      TextFormField(
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: PhoneNumbercontroller,
                        cursorColor: Colors.black,
                        cursorWidth: 2,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            hintText: ' Enter Phone Number',
                            hintStyle: TextStyle(fontSize: 13),
                            contentPadding: EdgeInsets.fromLTRB(40, 10, 10, 10),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey[300]!, width: 1.1)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: const Color.fromARGB(
                                        255, 186, 186, 186),
                                    width: 1.1))),
                        validator: (value) {
                          if (value!.length != 10) {
                            return 'Provide a Valid Phone Number';
                          } else {
                            isEmailValid = true;
                          }

                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            PhoneForNextpage = PhoneNumbercontroller.text;
                          });
                          if (value.length < 10) {
                            setState(() {
                              isEmailValid = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 80,
          child: Column(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(360, 40)),
                  backgroundColor: MaterialStateProperty.all<Color?>(
                      isEmailValid ? Colors.amberAccent[700] : Colors.grey),
                  // elevation: MaterialStateProperty.all<double>(0),
                  // shadowColor:
                  //     MaterialStateProperty.all<Color>(Colors.transparent),
                  // splashFactory: NoSplash.splashFactory,
                  overlayColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: Text("Proceed"),
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    otpVerification.verifyPhoneNumber("+91${PhoneForNextpage}");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OtpPage()));
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: const TextSpan(
                    text: 'By continuing,you agree to our',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Terms of Service ',
                          style:
                              TextStyle(decoration: TextDecoration.underline)),
                      TextSpan(text: 'and'),
                      TextSpan(
                          text: ' Privacy Policy',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ))
                    ]),
              )
              // Text(
              //   "By continuing,you agree to our Terms of Service and Privacy Policy",
              //   style: TextStyle(fontSize: 10),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
