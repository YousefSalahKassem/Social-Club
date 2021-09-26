import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/Stories/StoriesHelper.dart';
import 'package:socialclub/screens/Stories/Stories_widget.dart';

class Stories extends StatefulWidget {
late final DocumentSnapshot documentSnapshot;
Stories({required this.documentSnapshot});
  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  final ConstantColors constantColors=ConstantColors();
  final StoryWidget storyWidget=StoryWidget();
  CountDownController _controller = CountDownController();
@override
  void initState() {
    super.initState();
    Provider.of<StoriesHelper>(context,listen: false).storyTimePosted(widget.documentSnapshot['time']);
    Provider.of<StoriesHelper>(context,listen: false).addSeenStamp(context, widget.documentSnapshot.id, FirebaseAuth.instance.currentUser!.uid, widget.documentSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      body: GestureDetector(
        onPanUpdate: (update){
          if(update.delta.dx>0){
            Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.topToBottom));
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(imageUrl: widget.documentSnapshot['image'],fit: BoxFit.contain,)
                    ),
                  ],
                ),
              ),
            ),
            Positioned(top: 30,child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: Row(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        backgroundColor: constantColors.darkColor,
                        backgroundImage: NetworkImage(widget.documentSnapshot['userimage']),
                        radius: 25,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width*.5,
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*.9),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(widget.documentSnapshot['username'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),
                        Text(Provider.of<StoriesHelper>(context,listen: false).getStoryTime,style: TextStyle(color: constantColors.greenColor,fontWeight: FontWeight.bold,fontSize: 12),),
                      ],),
                    ),
                  ),
                  FirebaseAuth.instance.currentUser!.uid==widget.documentSnapshot['useruid']?InkWell(onTap: (){storyWidget.showViewers(context, widget.documentSnapshot.id, widget.documentSnapshot['useruid']);},child: Container(
                    height: 30,
                    width: 55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(FontAwesomeIcons.solidEye,color: constantColors.yellowColor,size: 16,),
                        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('stories').doc(widget.documentSnapshot.id).collection('seen').snapshots()
                            ,builder: (context,snapshot){
                          if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                          else{return Text(snapshot.data!.docs.length.toString(),style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),);
                            }
                            })
                      ],
                    ),
                  ),):Container(height: 0,width: 0,),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularCountDownTimer(
                      controller: _controller,
                      isTimerTextShown: false,
                      duration: 15,
                      fillColor: constantColors.blueColor,
                      height: 20,
                      onComplete: (){Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.topToBottom));},
                      width: 20,
                      ringColor: constantColors.darkColor,),
                    ),
                  FirebaseAuth.instance.currentUser!.uid==widget.documentSnapshot['useruid']?IconButton(onPressed: (){
                    showMenu(color: constantColors.blueGreyColor,context: context, position: RelativeRect.fromLTRB(300, 70, 0, 0), items: [
                    PopupMenuItem(child: FlatButton.icon(color: constantColors.blueColor,onPressed: (){
                      Navigator.pop(context);
                      storyWidget.addToHighLights(context, widget.documentSnapshot['image'],_controller);}, icon: Icon(FontAwesomeIcons.archive,color: constantColors.whiteColor,), label: Text('Add To Highlights',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),))),
                    PopupMenuItem(child: FlatButton.icon(color: constantColors.redColor,onPressed: (){FirebaseFirestore.instance.collection('stories').doc(FirebaseAuth.instance.currentUser!.uid).delete().whenComplete((){
                      Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.topToBottom));
                    });}, icon: Icon(FontAwesomeIcons.trashAlt,color: constantColors.whiteColor,), label: Text('Delete',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),))),
                  ]);},icon: Icon(EvaIcons.moreVertical,color: constantColors.whiteColor,)):Container(height: 0,width: 0,)
                ],
              ),
            ),),
          ],
        ),
      ),
    );
  }
}
