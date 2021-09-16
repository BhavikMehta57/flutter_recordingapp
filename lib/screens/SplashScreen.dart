import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recording_app/home/home.dart';
import 'package:recording_app/authentication/Login.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:recording_app/main/utils/AppColors.dart';

class SDSplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  _SDSplashScreenState createState() => _SDSplashScreenState();
}

class _SDSplashScreenState extends State<SDSplashScreen>
    with SingleTickerProviderStateMixin {
  startTime() async {
    var _duration = Duration(seconds: 1);
    return Timer(_duration, navigate);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigate() async {
    /// if logged in redirect to home screen
    if (FirebaseAuth.instance.currentUser != null) {
      print("Splash screen, user found!");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        ),
      );
    }

    /// else redirect to Login screen
    else {
      Login().launch(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: appColorPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Text(
                "Recording App",
                style: secondaryTextStyle(
                  size: 25,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
