import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/LandingPage/Landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConstantColors constantColors=ConstantColors();

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), ()=>(FirebaseAuth.instance.currentUser!=null)?Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight)):Navigator.pushReplacement(context, PageTransition(child: Landingpage(), type: PageTransitionType.leftToRight)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: constantColors.darkColor,
    body: Center(
      child: RichText(text: TextSpan(
        text: 'Social',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: constantColors.whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Club',
            style: TextStyle(
            fontFamily: 'Poppins',
              color: constantColors.blueColor,
              fontWeight: FontWeight.bold,
              fontSize: 34,
      ),
          )
        ]
      )),
    ),
    );
  }
}
