import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/services/FirebaseOperations.dart';

class HomePageHelper with ChangeNotifier{
  ConstantColors constantColors=ConstantColors();


  Widget bottomNavBar(BuildContext context,int index,PageController pageController){
    return CustomNavigationBar(
    currentIndex: index,
    bubbleCurve: Curves.bounceIn,
    scaleCurve: Curves.decelerate,
    selectedColor: constantColors.blueColor,
    unSelectedColor: constantColors.whiteColor,
    strokeColor: constantColors.blueColor,
    scaleFactor: .5,
    iconSize: 30,
    backgroundColor: Color(0xff040307),
    onTap: (value){
      index=value;
      pageController.jumpToPage(value);
      notifyListeners();
    }
    ,items: [
      CustomNavigationBarItem(icon: Icon(EvaIcons.home)),
      CustomNavigationBarItem(icon: Icon(Icons.message_rounded)),
      CustomNavigationBarItem(icon: Icon(FontAwesomeIcons.userAstronaut)),
    ]);
  }
}