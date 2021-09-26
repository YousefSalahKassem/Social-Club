import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/AltPtofile/alt_profileHelper.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';

class AltProfile extends StatelessWidget {
  late  final String userUid;

  AltProfile({required this.userUid});

  ConstantColors constantColors=ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.rightToLeft));},
            icon: Icon(Icons.arrow_back_ios_rounded,color: constantColors.whiteColor,)),
        title: RichText(text: TextSpan(text: 'Social',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 20),
            children: <TextSpan>[TextSpan(text: 'Club',style: TextStyle(color: constantColors.blueColor,fontWeight: FontWeight.bold,fontSize: 20))])),
        actions:
        [
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight));},
              icon: Icon(EvaIcons.moreVertical,color: constantColors.whiteColor,)),
        ],
        backgroundColor: constantColors.blueGreyColor.withOpacity(.6),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12)),
              color: constantColors.blueGreyColor.withOpacity(.6),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(userUid).snapshots()
            ,builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }
              else{
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Provider.of<AltProfileHelper>(context,listen: false).headprofile(context, snapshot,userUid),
                    Provider.of<AltProfileHelper>(context,listen: false).divider(),
                    Provider.of<AltProfileHelper>(context,listen: false).middleprofile(context, snapshot,userUid),
                    Provider.of<AltProfileHelper>(context,listen: false).footerProfile(context, snapshot),

                  ],
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}
