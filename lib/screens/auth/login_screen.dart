import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _isAnimate = true;
      setState(() {});
    });
  }

  _handleGoogleButtonClick() {
    // for showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then(
      (user) {
        // for hiding progress bar
        Navigator.pop(context);

        if (user != null) {
          log("\nUser: ${user.user}");
          log("\nUserAdditionalInfo: ${user.additionalUserInfo}");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
      },
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      if (mounted) {
        Dialogs.showSnackbar(context, "Something Went Wrong (Check Internet!)");
      }
      return null;
    }
  }

  // sign out function
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
  Widget build(BuildContext context) {
    // initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      // appbar
      appBar: AppBar(
        title: const Text("Welcome to Asn Chat"),
      ),

      // body
      body: Stack(children: [
        // app logo
        AnimatedPositioned(
          top: mq.height * .15,
          right: _isAnimate ? mq.width * .25 : -mq.width * .5,
          width: mq.width * .5,
          duration: const Duration(seconds: 1),
          child: Image.asset("images/splash.png"),
        ),

        // google login button
        Positioned(
          bottom: mq.height * .15,
          left: mq.width * .05,
          width: mq.width * .9,
          height: mq.height * .07,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                _handleGoogleButtonClick();
              },
              icon: Padding(
                padding: EdgeInsets.only(right: mq.width * .05),
                child: Image.asset(
                  "images/google.png",
                  height: mq.height * .04,
                ),
              ),
              label: const Text(
                "Login with Google",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )),
        ),
      ]),
    );
  }
}
