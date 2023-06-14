
import 'package:firebase_auth/firebase_auth.dart';

import 'libEmail.dart';

class phoneOTPAuth {
  var VerficationId = '';
  ConfirmationResult? confirmationResult;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> phoneAuthendication(String phoneNumber) async {
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 90),
        verificationCompleted: (PhoneAuthCredential credentials) async {
          await auth.signInWithCredential(credentials);
          print("Verification Completed");
        },
        verificationFailed: (FirebaseAuthException error) async {
          print('Error:${error.toString()}');
        },
        codeSent: (String verficationId, int? resendtoken) async {
          // this.confirmationResult = ConfirmationResult(verficationId,resendtoken);
          print('Verification code sent. VerificationId: $verficationId');

          String smscode = '12345';
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verficationId, smsCode: smscode);
          await auth.signInWithCredential(credential);
        },
        codeAutoRetrievalTimeout: (String verficationId) {});
  }

}

class OTPVerification {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var VerficationId = '';
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Verification Completed");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification Failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        this.VerficationId = verificationId;
        print("Verification ID: $verificationId");
        verificationIdForPhoneAuth = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Verification ID: $verificationId");
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      var credentials = await _auth.signInWithCredential(
          PhoneAuthProvider.credential(
              verificationId: verificationIdForPhoneAuth, smsCode: otp));

      return credentials.user != null ? true : false;
    } catch (e) {
      print(verificationIdForPhoneAuth);
      print("Failed to verify OTP: ${e.toString()}");
      return false;
    }
  }
}
