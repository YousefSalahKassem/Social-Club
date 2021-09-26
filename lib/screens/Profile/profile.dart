import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/LandingPage/Landing_screen.dart';
import 'package:socialclub/screens/Profile/ProfileHelpers.dart';
import 'package:socialclub/services/authentication.dart';

class Profile extends StatelessWidget {
  ConstantColors constantColors=ConstantColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constantColors.blueGreyColor.withOpacity(0.4),
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Provider.of<ProfileHelpers>(context,listen: false).showSettings(context);
        }, icon: Icon(EvaIcons.settings2Outline,color: constantColors.lightBlueColor,)),
        actions: [
          IconButton(onPressed: (){
            Provider.of<ProfileHelpers>(context,listen: false).logOutDialog(context);

          }, icon: Icon(EvaIcons.logInOutline,color: constantColors.greenColor,))
        ],
        title: RichText(text: TextSpan(
            text: 'My',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: constantColors.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Profile',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: constantColors.blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            ]
        )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: constantColors.blueGreyColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid
              ).snapshots(),
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }
                else{
                  return new Column(
                    children: [
                      Provider.of<ProfileHelpers>(context,listen: false).headerProfile(context, snapshot),
                      Provider.of<ProfileHelpers>(context,listen: false).divider(),
                      Provider.of<ProfileHelpers>(context,listen: false).middleprofile(context, snapshot),
                      Provider.of<ProfileHelpers>(context,listen: false).footerProfile(context, snapshot),
                    ],
                  );
                }
              },
            ),

          ),
        ),
      ),
    );
  }
}
