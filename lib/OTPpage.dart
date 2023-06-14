import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:rapido/Rapido_methods.dart';

import 'allowLocationpage.dart';
import 'libEmail.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  OTPVerification otpVerification = OTPVerification();
  String otp = "";
  bool isotpFull = false;
  int timeDuration = 15;
  Timer? timer;
  bool stoping = false;
  @override
  void initState() {
    super.initState();
    RunningTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void RunningTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeDuration > 0) {
          timeDuration--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double heights = MediaQuery.of(context).size.height;
    double widths = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(
            children: [
              Container(
                height: heights - 500,
                width: widths,
                child: Image.asset("android/assets/EnterOtp3.png"),
              ),
              Positioned(
                  left: widths - 382,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back))),
              Positioned(
                  top: 0,
                  right: 20,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.help_center)),
                      Text("Help")
                    ],
                  ))
            ],
          ),
          SizedBox(
            width: widths - 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter the OTP",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            height: 7,
          ),
          SizedBox(
            width: widths - 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "We have sent an OTP to ${PhoneForNextpage}",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: OTPTextField(
              length: 6,
              width: widths - 50,
              fieldWidth: 50,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textFieldAlignment: MainAxisAlignment.spaceBetween,
              fieldStyle: FieldStyle.box,
              onCompleted: (value) => setState(() {
                isotpFull = true;
                otpvaliadtion = value;

                otp = value;

                print("otp :$value");
              }),
              onChanged: (value) {
                // print(otp.length);
              },
            ),
          ),
          SizedBox(
            width: widths - 50,
            child: Row(
              children: [
                timeDuration != 0
                    ? Container(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          color: Colors.amber,
                          strokeWidth: 2,
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 8,
                ),
                Row(
                  children: [
                    Visibility(
                      visible: timeDuration != 0,
                      child: Text(
                        "Auto verifying",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                    Padding(
                      padding: timeDuration != 0
                          ? EdgeInsets.only(left: 145)
                          : EdgeInsets.only(left: 245),
                      child: RichText(
                        text: TextSpan(
                            text: 'Resend OTP in  ',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[500]),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '${timeDuration}s',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 11)),
                            ]),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
          ),
          Visibility(
            visible: timeDuration == 0,
            child: SizedBox(
              width: widths - 225,
              child: Text(
                "Didn't receive OTP ? Resend OTP via",
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
          ),
          Visibility(
            visible: timeDuration == 0,
            child: SizedBox(
              width: widths - 270,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset(
                            "android/assets/whatsapp_logo.png",
                          ))),
                  Text(
                    "Whatsapp",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: timeDuration == 0,
            child: SizedBox(
              width: widths - 270,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset(
                            "android/assets/Gmail-logo.png",
                          ))),
                  Text(
                    "Gmail",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
      bottomNavigationBar: Container(
        height: 80,
        child: Column(
          children: [
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(360, 40)),
                backgroundColor: MaterialStateProperty.all<Color?>(
                    isotpFull ? Colors.amberAccent[700] : Colors.grey),
                // elevation: MaterialStateProperty.all<double>(0),
                // shadowColor:
                //     MaterialStateProperty.all<Color>(Colors.transparent),
                // splashFactory: NoSplash.splashFactory,
                // overlayColor:
                //     MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              child: Text("Register"),
              onPressed: () async {
                //print(otpvaliadtion);
                //print(verificationIdForPhoneAuth);

                if (otp.isNotEmpty) {
                  bool isotpVerified =
                      await otpVerification.verifyOtp(otpvaliadtion);
                  print("verifyotp:${isotpVerified}");
                  if (isotpVerified) {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => LocationPage()));
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (context) => LocationPage()));
                  }
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
                        style: TextStyle(decoration: TextDecoration.underline)),
                    TextSpan(text: 'and'),
                    TextSpan(
                        text: ' Privacy Policy',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ))
                  ]),
            )
          ],
        ),
      ),
    ));
  }
}
