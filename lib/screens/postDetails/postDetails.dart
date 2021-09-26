import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/postDetails/postDetails_helper.dart';

class PostDetails extends StatefulWidget {
  @override
  _PostDetailsState createState() => _PostDetailsState();
  late DocumentSnapshot documentSnapshot;

  PostDetails({required this.documentSnapshot});
}

class _PostDetailsState extends State<PostDetails> {
  ConstantColors constantColors=ConstantColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.rightToLeft));}, icon: Icon(Icons.arrow_back_ios_rounded,color: constantColors.whiteColor,)),
        backgroundColor: constantColors.blueGreyColor.withOpacity(0.6),
        centerTitle: true,
         title: RichText(text: TextSpan(
          text: 'Social',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: constantColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'Feed',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: constantColors.blueColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          ]
      )),    ),
      body: Provider.of<PostDetailsHelper>(context,listen: false).feedBody(context, widget.documentSnapshot),
    );
  }
}
