import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/Chatroom/chatroom.dart';
import 'package:socialclub/screens/Feed/feed.dart';
import 'package:socialclub/screens/HomePage/home_page_helper.dart';
import 'package:socialclub/screens/Profile/profile.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:socialclub/services/authentication.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ConstantColors constantColors=ConstantColors();
  final PageController homepageController=PageController();
  int pageIndex=0;



  @override
  void initState() {
    super.initState();
    Provider.of<FirebaseOperations>(context,listen: false).initUserData(context).whenComplete(() {setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    ConstantColors constantColors=ConstantColors();
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      body: PageView(
        controller: homepageController,
        children: [
          Feed(),
          ChatRoom(),
          Profile()
        ],
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (page){
          setState(() {
            pageIndex=page;
          });
        },
      ),
      bottomNavigationBar:Provider.of<HomePageHelper>(context,listen: false).bottomNavBar(context,pageIndex, homepageController)
    );
  }
}
